#!/usr/bin/env python3
# coding: utf-8

import argparse

def GetArgs():
    parser = argparse.ArgumentParser(description='Script for change bed file to chr:start-end format.')
    parser.add_argument('--bed', dest='bed', help='bed file', required=True)
    parser.add_argument('--type', dest='typ', help='region or csv', required=True)
    parser.add_argument('--out', dest='out', help='out file name', required=True)
    args = parser.parse_args()
    return args 

def FormatConvert(bed, typ, out):
    bed_file = open(bed)
    out_file = open(out,'w')
    for line in bed_file:
        ele = line.strip().split("\t")
        chrom = ele[0]
        start = ele[1]
        end = ele[2]
        if typ == "region":
            out_file.write(chrom+":"+start+"-"+end+"\n")
        if typ == "csv":
            out_file.write(chrom+","+start+","+end+"\n")
    bed_file.close()
    out_file.close()

def main():
    args = GetArgs()
    bed = args.bed
    typ = args.typ
    out = args.out
    FormatConvert(bed, typ, out)

if __name__=="__main__":
    main()
