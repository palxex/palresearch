#!/usr/bin/env python
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import re

def getname(i):
    return prefix+str(i)+"."+postfix

def ensMKF():
    maxfiles=10000
    for i in range(0,maxfiles):
        filename=getname(i)
        if not os.path.isfile(filename):
            maxfiles=i
            break
    indexes=struct.pack("<h",maxfiles+1)
    offset=maxfiles+1
    for i in range(0,maxfiles):
        filename=getname(i)
        offset=offset+os.path.getsize(filename)/2
        if i == maxfiles-1:
            offset=0 #hack
        indexes = indexes + struct.pack("<h",offset)
    with open(prefix+".smkf", 'wb') as mkffile:
        mkffile.write(indexes)
        for i in range(0,maxfiles):
            with open(prefix+str(i)+"."+postfix, 'rb') as subfile:
                mkffile.write(subfile.read())

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='sMKF pack util')
    parser.add_argument('--prefix', required=True,
                       help='prefix for files to pack')
    parser.add_argument('--postfix', required=True,
                       help='postfix for files to pack')

    args = parser.parse_args()
    prefix=args.prefix
    postfix=args.postfix
    ensMKF()