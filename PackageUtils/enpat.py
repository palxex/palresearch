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
    pat = Image.open(args.image).convert("RGB") # remove Alpha
    bytes = "".join([chr(ord(x)/4) for x in pat.tobytes()])
    
    if args.show:
        pat.show(); 
    
    if args.output:
        args.output.write(bytes)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for generating PAT from 16x16 image')
    parser.add_argument('image', type=argparse.FileType('rb'),
                       help='image file to encode')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'),
                       help='resulting bmp')
    parser.add_argument('--show', action='store_true', default=False,
                       help='show palette png')

    args = parser.parse_args()
    if not args.show and args.output == None:
        print "Either Show or Specify output filename"
    else:
        process()