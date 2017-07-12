#!/usr/bin/env python
# -*- coding: utf-8 -*-  
import argparse
import os
import utilcommon
from ctypes import *

def deYJ1(input,pallib,output):
    dll=cdll.LoadLibrary(pallib.name)
    buffer=POINTER(c_byte)()
    length=c_int()
    inbuf=input.read()
    dll.encodeyj1(inbuf,len(inbuf),byref(buffer),byref(length))
    output.write(string_at(buffer,length));
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='YJ1 compacting util')
    parser.add_argument('file', type=argparse.FileType('rb'),
                       help='file to compact')
    parser.add_argument('-l','--lib', type=argparse.FileType('rb'), default=os.path.dirname(__file__)+"/../PalLibrary/libpallib."+utilcommon.getOSDynamicLibraryExtension(),
                       help='path for pallib')
    parser.add_argument('-o','--output', type=argparse.FileType('wb'), required=True,
                       help='filename for packed file')

    args = parser.parse_args()
    deYJ1(args.file,args.lib,args.output)