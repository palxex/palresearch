#!/usr/bin/env python
# -*- coding: utf-8 -*-  
import argparse
import os
import utilcommon
from ctypes import *

def deYJ2(input,pallib,output):
    dll=cdll.LoadLibrary(pallib.name)
    buffer=POINTER(c_byte)()
    length=c_int()
    dll.decodeyj2(input.read(),byref(buffer),byref(length))
    output.write(string_at(buffer,length));

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='YJ2 extraction util')
    parser.add_argument('YJ2', type=argparse.FileType('rb'),
                       help='YJ2 file to extract')
    parser.add_argument('-l','--lib', type=argparse.FileType('rb'), default=os.path.dirname(__file__)+"/../PalLibrary/libpallib."+utilcommon.getOSDynamicLibraryExtension(),
                       help='path for pallib')
    parser.add_argument('-o','--output', type=argparse.FileType('wb'), required=True,
                       help='filename for unpacked file')

    args = parser.parse_args()
    deYJ2(args.YJ2,args.lib,args.output)
    