#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import argparse
import os
import utilcommon
from ctypes import *

def deYJ1(input):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    buffer=POINTER(c_byte)()
    length=c_int()
    dll.decodeyj1(input,byref(buffer),byref(length))
    return string_at(buffer,length)

def process(inputf,output):
    output.write(deYJ1(inputf.read()))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='YJ1 extraction util')
    parser.add_argument('YJ1', type=argparse.FileType('rb'),
                       help='YJ1 file to extract')
    parser.add_argument('-o','--output', type=argparse.FileType('wb'), required=True,
                       help='filename for unpacked file')

    args = parser.parse_args()
    if utilcommon.PallibExist():
        process(args.YJ1,args.output)
    else:
        print "PalLib not exist. Please build it first in PalLibrary folder"