#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import os
import utilcommon
from ctypes import *

def enYJ2(input):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    buffer=POINTER(c_byte)()
    length=c_int()
    inbuf=input
    if len(inbuf) == 0:
    	return b""
    dll.encodeyj2(inbuf,len(inbuf),byref(buffer),byref(length),c_int(1))
    return string_at(buffer,length)
    
def process(inputf,output):
    output.write(enYJ2(inputf.read()))
    output.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='YJ2 compacting util')
    parser.add_argument('file', type=argparse.FileType('rb'),
                       help='file to compact')
    parser.add_argument('-o','--output', type=argparse.FileType('wb'), required=True,
                       help='filename for packed file')

    args = parser.parse_args()
    if utilcommon.PallibExist():
        process(args.file,args.output)
    else:
        print("PalLib not exist. Please build it first in PalLibrary folder")