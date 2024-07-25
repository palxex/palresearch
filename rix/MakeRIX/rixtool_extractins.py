#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import os
import traceback
import struct

INS_SIZE=64
INS_WORDS=28

usage=''
def ParseOptions():
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--rix', type=argparse.FileType('rb'), dest='rixfile',
            help='rix file')
    parser.add_argument('-o', '--insoffset', dest='insoffset',
            help='ins offset(default 8)', default=8)
    parser.add_argument('-v', '--verbose',
                    action='store_true', dest='verbose', default=False,
                    help='print verbose log')
    args = parser.parse_args()
    usage=parser.print_help()
    return args

def main():
    options = ParseOptions()

    rix_bytes=options.rixfile.read()
        
    inses_begin = struct.unpack("<H",rix_bytes[options.insoffset:options.insoffset+2])[0]
    inses_end = struct.unpack("<H",rix_bytes[12:14])[0]
    inses_num = (inses_end-inses_begin)//INS_SIZE
    
    for i in range(1,inses_num+1):
        with open("ins%d.ins" % i,"wb") as f:
            ins_begin=inses_begin+INS_SIZE*(i-1)
            ins_end=ins_begin+INS_WORDS*2
            if options.verbose:
                print("going to dump ins %d with range %d-%d"%(i,ins_begin,ins_end))
            f.write(b'\x00\x00'+rix_bytes[ins_begin:ins_end]+b'\x00'*20+b'\x01\x00')

if __name__ == '__main__':
    main()
