#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import enmkf
import enyj1
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw
import tempfile
import shutil

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

def process():
    pat = utilcommon.getPalette(args.palette,args.palette_id)
    
    tempdir=tempfile.mkdtemp()
    if args.saveraw:
    	print("working dir:"+tempdir)
    
    orig=Image.open(args.gif)
    memset(prev_frame,0,length)
    for frame in range(0, orig.n_frames):
    	orig.seek(frame)
    	im = orig
    	(im,ima) = utilcommon.convertImage(im, args, silent=True)
        if args.saveraw:
           im.save(tempdir+"/temp%d.png"%frame)
           open(tempdir+"/temp%d.raw"%frame,"wb").write(im.tobytes())
    	buf = enRNG(prev_frame,im.tobytes())
        if args.saveraw:
           open(tempdir+"/temp%d.rf"%frame,"wb").write(buf)
    	buf2 = enyj1.enYJ1(buf)
    	open(tempdir+"/temp%d.yj1"%frame,"wb").write(buf2)
    	memmove(prev_frame,orig.tobytes(),length)
    
    enmkf.enMKF(tempdir+"/temp","yj1")
    shutil.copyfile(tempdir+"/temp.mkf",args.output.name)
    if not args.saveraw:
    	shutil.rmtree(tempdir)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for converting GIF animation to RNG')
    parser.add_argument('gif', type=argparse.FileType('rb'),
                       help='gif file to encode')
    parser.add_argument('-o','--output', required=True, type=argparse.FileType('wb'),
                       help='resulting rng')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), required=True, 
                       help='PAT file')
    parser.add_argument('-i', '--palette_id', type=int, default=0,
                       help='palette id')
    parser.add_argument('-d', '--transparent_palette_index', default=0xff,
                       help='transparent index for color in palette; default 255')
    parser.add_argument('--quantize', action='store_true', default=False,
                       help='for images not with pal palette; notice: expensive!')
    parser.add_argument('--dither', action='store_true', default=False,
                       help='whether ditter color when quantizing')
    parser.add_argument('--saveraw', action='store_true', default=False,
                       help='save decoded raw png data')

    args = parser.parse_args()
    process()