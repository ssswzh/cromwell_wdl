#!/usr/bin/env python3
"""
Merge multi SV annotation table to on table
"""
import sys

def table_merge(annovar_table,svan_table):
    merged_table = []
    # read annovar_table
    with open(annovar_table,"r") as io:
        header = io.readline()
        field_names = header.strip().split("\t")
        fields_names_dict = {}
        for i in range(len(field_names)):
            if field_names[i] not in fields_names_dict:
                fields_names_dict[field_names[i]] = i
            else:
                raise RuntimeError("Duplicated field name {}".format(
                    field_names[i]))
        annovar_annot_names = field_names[5:-5]
        # dict, key SVID, value record
        annovar_table_dict = {}
        for line in io:
            fields = line.strip().split("\t")
            svid = fields[fields_names_dict["SVID"]]
            if svid not in annovar_table_dict:
                annovar_table_dict[svid] = fields
            else:
                raise RuntimeError("Duplicated SV ID {}".format(svid))

    # read svan_table
    with open(svan_table,"r") as io:
        header = io.readline()
        field_names = header.strip().split("\t")
        fields_names_dict = {}
        for i in range(len(field_names)):
            if field_names[i] not in fields_names_dict:
                fields_names_dict[field_names[i]] = i
            else:
                raise RuntimeError("Duplicated field name {}".format(
                    field_names[i]))
        for line in io:
            fields = line.strip().split("\t")
            #Chr    Start   End     SVTPE   SVID    SVLEN   RE      INFO Annotations
            svid = fields[fields_names_dict["SVID"]] # SVID

            # 20180921 modified , add AF, FORMAT and sample
            info = fields[fields_names_dict["INFO"]]
            info_fields = info.split(";")
            info_origin = ";".join(info_fields[:-2])
            alle_freq = "NA"
            vcf_format = "NA"
            vcf_sample1 = "NA"
            for i in info_fields:
                if "=" in i:
                    t = i.split("=")
                    ikey = t[0]
                    ivalue = t[1]
                    if ikey == "AF":
                        alle_freq = ivalue
                    if ikey == "FORMAT":
                        vcf_format = ivalue
                    if ikey == "SAMPLE_FORMAT":
                        vcf_sample1 = ivalue

            for i in [vcf_sample1, vcf_format, alle_freq]:
                fields.insert(7, i)

            annovar_table_dict[svid][5:-5].reverse()
            annovar_table_record = annovar_table_dict[svid][5:-5]
            annovar_table_record.reverse()
            for i in annovar_table_record:
                fields.insert(10, i)

            if svid in annovar_table_dict:
                new_line = "\t".join(fields)+"\n"
                merged_table.append(new_line)
            else:
                raise RuntimeError("'SVID' in SVAN out table is not included"
                        " in annovar table, please make sure you are using the"
                        " 'same' input for 'svannot' and 'SVAN'")
        # header
        for i in ["SAMPLE_FORMAT","FORMAT","AF"]:
            field_names.insert(7, i)

        annovar_annot_names.reverse()
        for i in annovar_annot_names:
            field_names.insert(10, i)

        out_header = "\t".join(field_names)+"\n"
        merged_table.insert(0, out_header)

    return merged_table


def main():
    if len(sys.argv) != 4:
        print("python3 table_maker.py omim_table.xls svan_table.xls outfile")
    else:
        merged_table = table_merge(sys.argv[1],sys.argv[2])
        print("table_maker.py consume memory is {} bytes.".format(sys.getsizeof(merged_table)))
        with open(sys.argv[3],"w") as io:
            io.writelines(merged_table)


if __name__ == "__main__":
    main()

