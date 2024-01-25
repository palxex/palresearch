#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import re

def getname(i):
    return prefix+str(i)+"."+postfix
    
def roundtoeven(i):
    return i if i%2==0 else i+1

def ensMKF():
    maxfiles=10000
    for i in range(0,maxfiles):
        filename=getname(i)
        if not os.path.isfile(filename):
            maxfiles=i
            break
    packarg="<H"
    indexes=struct.pack(packarg,maxfiles+1)
    offset=maxfiles+1
    for i in range(0,maxfiles):
        filename=getname(i)
        offset=offset+roundtoeven(os.path.getsize(filename))//2
        if i == maxfiles-1:
            offset=0 #hack
        indexes = indexes + struct.pack(packarg,offset)
    with open(prefix+".smkf", 'wb') as mkffile:
        mkffile.write(indexes)
        for i in range(0,maxfiles):
            with open(prefix+str(i)+"."+postfix, 'rb') as subfile:
                content=subfile.read()
                if len(content) %2 == 1:
                    content+='\x00'
                mkffile.write(content)

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