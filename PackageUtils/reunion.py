#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import re
import enmkf
import enyj1
import enyj2
import utilcommon

def getname(i):
    return os.path.join("map","map%04d"%i)

def reunion(args):
    maxfiles=10000
    for i in range(0,maxfiles):
        filename=getname(i)
        if not os.path.isfile(filename):
            maxfiles=i
            break
    indexes=struct.pack("<I",(maxfiles+1)*4)
    offset=(maxfiles+1)*4
    conts={}
    for i in range(0,maxfiles):
        filename=getname(i)
        cont=b''
        if args.progress:
            utilcommon.printProgressBar(i, maxfiles, prefix = 'Progress:', suffix = 'Complete', length = 50)
        with open(getname(i), 'rb') as subfile:
            cont=subfile.read()
            cont=cont[0:len(cont)//2]
            if args.algorithm is not None:
                if args.algorithm.lower() == 'YJ1'.lower():
                    cont=enyj1.enYJ1(cont)
                elif args.algorithm.lower() == "YJ2".lower():
                    cont=enyj2.enYJ2(cont)
        offset=offset+len(cont)
        conts[i]=cont
        indexes = indexes + struct.pack("<I",offset)
    with open("map/map.mkf", 'wb') as mkffile:
        mkffile.write(indexes)
        for i in range(0,maxfiles):
            mkffile.write(conts[i])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='MapEditor repack util')
    parser.add_argument('--algorithm', '-a', required=False,
                       help='enflating algorithm; yj1, yj2, or default none')
    parser.add_argument('--progress', '-P', action="store_true", default=False,
                       help='show progress bar')

    args = parser.parse_args()
    reunion(args)