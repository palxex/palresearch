#!/usr/bin/env python3
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
    f.seek(0,os.SEEK_END)
    total_length=f.tell()
    f.seek(0,os.SEEK_SET)
    first_index, = struct.unpack("<I",f.read(4))
    subfiles = first_index//4 -1

    #addition check whether a LAST piece needed
    f.seek(subfiles*4,os.SEEK_SET)
    last_index,  = struct.unpack("<I",f.read(4))
    if last_index != 0 and last_index < total_length:
        subfiles=first_index

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