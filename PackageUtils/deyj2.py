#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import os
import utilcommon
from ctypes import *

def deYJ2(input):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    buffer=POINTER(c_byte)()
    length=c_int()
    dll.decodeyj2(input,byref(buffer),byref(length))
    return string_at(buffer,length)
    
def process(inputf,output):
    output.write(deYJ2(inputf.read()))
    output.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='YJ2 extraction util')
    parser.add_argument('YJ2', type=argparse.FileType('rb'),
                       help='YJ2 file to extract')
    parser.add_argument('-o','--output', type=argparse.FileType('wb'), required=True,
                       help='filename for unpacked file')

    args = parser.parse_args()
    if utilcommon.PallibExist():
        process(args.YJ2,args.output)
    else:
        print("PalLib not exist. Please build it first in PalLibrary folder")