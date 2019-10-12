#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

"""
This file is a simple app used to test HdlConvertor is a library functions.
(Icarus verilog like CLI API)
"""
import argparse
from hdlConvertor import HdlConvertor
from hdlConvertor.language import Language

VERILOG_VERSION_OPTS = {
    "v1995": Language.VERILOG_1995,
    "v2001-noconfig": Language.VERILOG_2001_NOCONFIG,
    "v2001": Language.VERILOG_2001,
    "v2005": Language.VERILOG_2005,
    "sv2005": Language.SYSTEM_VERILOG_2005,
    "sv2009": Language.SYSTEM_VERILOG_2009,
    "sv2012": Language.SYSTEM_VERILOG_2012,
    "sv2017": Language.SYSTEM_VERILOG_2017,
}

def main(std_ver, include_dirs, files):
    c = HdlConvertor()
    # c.preproc_macro_db.update(preproc_defs)
    if include_dirs is None:
        include_dirs = []
    c.parse(files, std_ver, include_dirs)

def parse_CLI_args():
    parser = argparse.ArgumentParser(description='HdlConvertor CLI app.')
    parser.add_argument('files', metavar='N', type=str, nargs='+',
                        help='HDL files to parse')
    parser.add_argument('--std', dest='std', action='store',
                        help='verilog standard to use (default sv2017)')
    parser.add_argument('-I', dest='include', action='append', type=str,
                        help='verilog standard to use (default sv2017)')
    
    args = parser.parse_args()
    return VERILOG_VERSION_OPTS[args.std], args.include, args.files

if __name__ == "__main__":
    main(*parse_CLI_args())
    
    