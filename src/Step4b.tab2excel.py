#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
tsv文件转换为excel文件
"""

# ---------
# Change Logs:
#
# ---------

__author__ = 'Li Pidong'
__email__ = 'lipidong@126.com'
__version__ = '0.0.1'
__status__ = 'Dev'

import sys
# reload(sys)
# sys.setdefaultencoding('utf-8')
import argparse
import logging
import pandas as pd

def log(file_name, logger_name='lipidong', quite=False):
    logger = logging.getLogger(logger_name)
    formatter = logging.Formatter("%(asctime)s-%(levelname)s-%(message)s",
                                 datefmt="%Y-%m-%d %H:%M:%S")
    handler = logging.FileHandler(file_name)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    if not quite:
        console = logging.StreamHandler()
        console.setLevel(logging.INFO)
        console.setFormatter(formatter)
        logger.addHandler(console)
    return logger

def get_args():
    parser = argparse.ArgumentParser(prog='tsv文件转换为excel文件')
    parser.add_argument('-i','--input_file', help='输入的tsv文件')
    parser.add_argument('-o','--output_file', help='输出的excel文件')
    parser.add_argument('--log', help='log file, default=.log', default='.log')
    parser.add_argument("--quite", help="increase output verbosity",
                         action="store_true")
    if len(sys.argv) == 1:
        parser.print_help()
        exit()
    return parser.parse_args()

def main():
    args = get_args()
    input_file = args.input_file
    output_file = args.output_file
    log_file = args.log
    quite = args.quite
    global logger
    logger = log(log_file, quite=quite)
    #df = pd.read_table(input_file, engine='c', dtype='str', index_col=False)
    df = pd.read_table(input_file, engine='c', dtype={"Start":int,"End":int,"SVLEN":int,"AF":float,"Gene.refGene":str,"GrandSV_Frequency":float}, index_col=False)  #SVLEN:NA
    df.to_excel(output_file, index=False, na_rep="NA")

if __name__ == '__main__':
    main()
