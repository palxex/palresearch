#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import demkf
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw

args=None

def process():
    im=Image.open(args.image)
    if im.width != 320 or im.height !=200:
        print "alert! not fit size for FBP"
        return
    if im.mode != "P": 
        print "This image have no palette, that implies not a image derle produces; turn on quantize automatically"
        args.quantize=True
        if args.palette == None:
            print "Invalid configuration! quantize must specify palette/id"
            return
    ima=im
    if args.quantize:
        pat = demkf.deMKF(args.palette,args.palette_id)
        if len(pat) > 768:
            pat=pat[0:768]
        pat="".join([chr(ord(x)*4) for x in pat])
        imp=Image.new("P",(16,16))
        imp.putpalette(pat)
        im=utilcommon.quantizetopalette(im,imp, 1 if args.dither else 0)
    args.output.write(im.tobytes())

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='convert BMP/PNG to RLE tool')
    parser.add_argument('image', type=argparse.FileType('rb'),
                       help='image file to encode')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'), required=True,
                       help='resulting rle')
    parser.add_argument('--quantize', action='store_true', default=False,
                       help='for images not with pal palette; notice: expensive!')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), 
                       help='PAT file for quantize')
    parser.add_argument('-i', '--palette_id',type=int, default=0,
                       help='palette id')
    parser.add_argument('--dither', action='store_true', default=False,
                       help='whether ditter color when quantizing')

    args = parser.parse_args()
                       
    if args.quantize and args.palette == None:
        print "invalid configuration! quantize must specify palette/id"
    else:
        process()