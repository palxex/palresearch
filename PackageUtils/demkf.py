#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import argparse
import struct
import os

def deMKF_mem(content,index):
    begin,end = struct.unpack("<II",content[index*4:(index+2)*4])
    return content[begin:end]

def deMKF(f,index):
    f.seek(0)
    return deMKF_mem(f.read(),index)

def process(f,postfix):
    mkf_name=os.path.basename(f.name)
    prefix=os.path.splitext(mkf_name)[0]
    first_index, = struct.unpack("<I",f.read(4))
    subfiles = first_index/4
    for i in range(0,subfiles):
        with open(prefix+str(i)+"."+postfix, 'wb') as subfile:
            subfile.write(deMKF(f,i))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='MKF unpack util')
    parser.add_argument('MKF', type=argparse.FileType('rb'), action="store",
                       help='MKF file to unpack')
    parser.add_argument('-p','--postfix', required=True,
                       help='postfix for unpacked files')

    args = parser.parse_args()
    process(args.MKF,args.postfix)