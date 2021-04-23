#!/usr/bin/env python3
# coding: utf-8

"""
Structure variation annotation using annovar
Suitable for sniffles or nanosv output vcf files
"""

import sys
import argparse
import os
import subprocess


import sv_vcf

#convert bed into annovar input
def bed_to_ainput(bed, prefix):
    out = open(prefix+".ainput", "w")
    with open(bed, "r") as bedio:
        for line in bedio:
            fields = line.strip().split("\t")
            fields[1] = str(int(fields[1])+1)
            fields.insert(3,"0")
            fields.insert(3,"0")
            new_line = "\t".join(fields)
            print(new_line, file=out)
    out.close()
    return prefix+".ainput" # return ainput path

def run_annovar(ainput, table_annovar, database, prefix):
    protocols = ",".join(["refGene",
    "cytoBand",
    "dgvMerged",
    "tfbsConsSites",
    "genomicSuperDups",
    "rmsk",
    "wgEncodeBroadHmmGm12878HMM",
    "wgEncodeBroadHmmH1hescHMM",
    "wgEncodeBroadHmmHepg2HMM",
    "wgEncodeBroadHmmHuvecHMM",
    "wgEncodeBroadHmmK562HMM",
    "cpgIslandExt",
    "targetScanS",
    "wgRna"])

    operations = "g,r,r,r,r,r,r,r,r,r,r,r,r,r"
    subprocess.run([
        "perl",
        table_annovar,
        ainput,
        database,
        "-buildver",
        "hg19",
        "-out",
        prefix,
        "-otherinfo",
        "-nastring",
        ".",
        "-remove",
        "-protocol",
        protocols,
        "--operation",
        operations])



def table_header(table,prefix):
    #replace  Otherinfo with SVTYPE ID SVLEN Support_reads_num comments
    out = open(prefix+".hg19_multianno.xls", "w")
    with open(table,"r") as table_io:
        header = table_io.readline()
        fields = header.strip().split("\t")
        fields.pop(-1)
        fields.extend(["SVTYPE", "SVID", "SVLEN", "RE", "INFO"])
        print("\t".join(fields), file=out)
        for line in table_io:
            print(line, file=out, end="")
    out.close()

def omimdb_dict(db):
    """
    grandbox omimdb
    #gene_symbol    gene_id OMIM_id  hpo_or_dis      chpo_or_dis     inheritance
    """
    db_dict = {}
    with open(db,"r") as io:
        header = io.readline()
        for line in io:
            fields = line.strip().split("\t")
            while len(fields) < 6:
                fields.append("NA")
            #remove gene_id from fields
            fields.pop(1)
            if fields[0] not in db_dict:
                db_dict[fields[0]] = fields
            else:
                raise RuntimeError("Duplicated gene symbol {}".format(gene_symbol))
    return db_dict

def annot_omimdb(annovar_tab, db, prefix):
    out = open(prefix+".hg19.omim_chpo.xls","w")
    with open(annovar_tab, "r") as annovar_tab_io:
        header = annovar_tab_io.readline()
        field_names = header.strip().split("\t")
        #find Gene.refGene
        try:
            ref_gene_name_idx = field_names.index("Gene.refGene")
        except ValueError:
            print("Bad annovar file format, \"Gene.refGene\" is not in the header!")
        #modified header
        field_names.insert(ref_gene_name_idx+4,"inheritance")
        field_names.insert(ref_gene_name_idx+4,"chpo_or_dis")
        field_names.insert(ref_gene_name_idx+4,"hpo_or_dis")
        field_names.insert(ref_gene_name_idx+4,"OMIM_id")
        print("\t".join(field_names), file=out)
        for line in annovar_tab_io:
            fields = line.strip().split("\t")
            ref_genes = fields[ref_gene_name_idx].split(",")
            annot = [[] for i in range(4)]
            for i in ref_genes:
                if i in db:
                    for j in range(4):
                        if db[i][j+1] != "NA" and db[i][j+1] != "null":
                            annot[j].append(db[i][j+1])
            annot_str = [";".join(i) for i in annot]
            for i in annot_str[::-1]:
                if i == "":
                    i = "."
                fields.insert(ref_gene_name_idx+4,i)
            print("\t".join(fields), file=out)
    out.close()


def get_args():
    parser = argparse.ArgumentParser(
        description="Structure variation annotation using annovar",
        usage="usage: %(prog)s [options]")
    parser.add_argument("--vcf",
        help="vcf file [default %(default)s]", metavar="FILE")
    parser.add_argument("--bed",
        help="bed file [default %(default)s]", metavar="FILE")
    parser.add_argument("--db",default="/home/yangqi/workdir/database/annovar/humandb1",
        help="Database directory [default %(default)s]",metavar="DIR")
    parser.add_argument("--annovar",default="/data/langna/tools/softwares/annovar/table_annovar.pl",
        help="Table Annovar [default %(default)s]",metavar="DIR")
    parser.add_argument("--prefix",
        help="output prefix [default %(default)s]", metavar="STR")
    parser.add_argument("--outdir", default=".", # default current work dir
        help="output directory [default %(default)s]", metavar="DIR")
    if len(sys.argv) <= 1:
        parser.print_help()
        exit()
    return parser.parse_args()

def main():
    args = get_args()

    # make dir
    if not os.path.exists(args.outdir):
        os.mkdir(args.outdir)

    prefix_with_dir = os.path.join(args.outdir, args.prefix)

    if args.vcf:
        bed = prefix_with_dir+".sv.bed"
        sv_vcf.vcf_to_bed(args.vcf,bed)
    elif args.bed:
        bed = args.bed

    ainput = bed_to_ainput(bed, prefix_with_dir)
    run_annovar(ainput, args.annovar, args.db, prefix_with_dir)
    table_header(prefix_with_dir+".hg19_multianno.txt", prefix_with_dir)
    # check omimdb
    if not os.path.exists(os.path.join(args.db,"omimdb")):
        raise FileNotFoundError("Can not find 'omimdb' in you database dir")
    annot_omimdb(prefix_with_dir+".hg19_multianno.xls",
            omimdb_dict(os.path.join(args.db,"omimdb")), prefix_with_dir)

if __name__ == '__main__':
    main()
    