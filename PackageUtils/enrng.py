#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import enmkf
import enyj1
import enyj2
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw
import tempfile
import shutil
import sys

import derng

args=None
length=320*200
ArrayType = c_int16 * length
prev_frame = ArrayType()

def enRNG(prev_frame,cur_frame):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    buffer=POINTER(c_byte)()
    len=c_int()
    dll.encoderng(prev_frame,cur_frame,byref(buffer),byref(len))
    return string_at(buffer,len)

def getname(prefix,i):
    return prefix+str(i)+".png"

def process():
    pat = utilcommon.getPalette(args)

    tempdir=tempfile.mkdtemp()
    if args.saveraw:
    	print("working dir:"+tempdir)

    maxfiles=10000
    for i in range(0,maxfiles):
        filename=getname(args.input_prefix,i)
        if not os.path.isfile(filename):
            maxfiles=i
            break

    # initialize with full transparent pixels
    memset(prev_frame,-1,length)
    for frame in range(0, maxfiles):
        im = Image.open(getname(args.input_prefix,frame))
        if args.progress:
            utilcommon.printProgressBar(frame+1, maxfiles, prefix = 'Progress:', suffix = 'Complete', length = 50)
        (im,ima) = utilcommon.convertImage(im, args, silent=True)
        if args.saveraw:
           im.save(tempdir+"/temp%d.png"%frame)
           open(tempdir+"/temp%d.raw"%frame,"wb").write(im.tobytes())
        buf = enRNG(prev_frame,im.tobytes())
        # HACKHACK; eliminate the padding introduced by the encoder to ensure bitwize exactness( BEFORE compression )
        if buf[-2:] == b'\x00\x00': 
            buf = buf[:-1]
        if args.saveraw:
            open(tempdir+"/temp%d.diff"%frame,"wb").write(buf)
        if args.algorithm.lower() == 'YJ1'.lower():
            buf2=enyj1.enYJ1(buf)
        elif args.algorithm.lower() == "YJ2".lower():
            buf2=enyj2.enYJ2(buf)
        open(tempdir+"/temp%d.yj1"%frame,"wb").write(buf2)
        # manually apply the patch, instead of directly using the new frame, since its unware of the transparent pixels
        derng.deRNG(buf,prev_frame)

    enmkf.enMKF(tempdir+"/temp","yj1")
    shutil.copyfile(tempdir+"/temp.mkf",args.output.name)
    if not args.saveraw:
    	shutil.rmtree(tempdir)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for converting PNG sequence animation to RNG')
    parser.add_argument('-u','--input_prefix', required=True,
                       help='input PNGs folder/prefix')
    parser.add_argument('-o','--output', required=True, type=argparse.FileType('wb'),
                       help='resulting rng')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), required=True, 
                       help='PAT file')
    parser.add_argument('-i', '--palette_id', type=int, default=0,
                       help='palette id')
    parser.add_argument('-n', '--night', action='store_true', default=False,
                       help='use night palette')
    parser.add_argument('--algorithm', '-a', required=True,
                       help='decompression algorithm')
    parser.add_argument('-d', '--transparent_palette_index', type=int, default=0xff,
                       help='transparent index for color in palette; default 255')
    parser.add_argument('--quantize', action='store_true', default=False,
                       help='for images not with pal palette; notice: expensive!')
    parser.add_argument('--dither', action='store_true', default=False,
                       help='whether ditter color when quantizing')
    parser.add_argument('--saveraw', action='store_true', default=False,
                       help='save decoded raw png data')
    parser.add_argument('--progress', '-P', action="store_true", default=False,
                       help='show progress bar')
    args = parser.parse_args()
    process()