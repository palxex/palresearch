#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import re

altScheme = False
verbose = False

def getname(prefix,postfix,i):
    if altScheme:
        return "{:03d}".format(i)+"."+postfix
    return prefix+str(i)+"."+postfix

def enMKF(prefix,postfix):
    maxfiles=10000
    if verbose:
        print("finding maximum number of files...")
    for i in range(0,maxfiles):
        filename=getname(prefix,postfix,i)
        if verbose:
            print("checking file: "+filename)
        if not os.path.isfile(filename):
            maxfiles=i
            break
    if verbose:
        print("maximum number of files found: "+str(maxfiles))
    indexes=struct.pack("<I",(maxfiles+1)*4)
    offset=(maxfiles+1)*4
    for i in range(0,maxfiles):
        filename=getname(prefix,postfix,i)
        offset=offset+os.path.getsize(filename)
        indexes = indexes + struct.pack("<I",offset)
    with open(prefix+".mkf", 'wb') as mkffile:
        mkffile.write(indexes)
        for i in range(0,maxfiles):
            with open(getname(prefix,postfix,i), 'rb') as subfile:
                mkffile.write(subfile.read())

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='MKF pack util')
    parser.add_argument('--prefix', required=True,
                       help='prefix for files to pack')
    parser.add_argument('--postfix', required=True,
                       help='postfix for files to pack')
    parser.add_argument('--altscheme', action='store_true', default=False,
                          help='use alternative naming scheme to find file(mainly for repacking midi from win98 resource): no prefix, 3 digit index')
    parser.add_argument('--verbose', action='store_true', default=False,
                          help='enable verbose output')

    args = parser.parse_args()
    altScheme = args.altscheme
    verbose = args.verbose
    enMKF(args.prefix, args.postfix)