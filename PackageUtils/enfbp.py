#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw

args=None

def process():
    im=Image.open(args.image)
    if im.width != 320 or im.height !=200:
        print("alert! not fit size for FBP")
        return
    (im,ima) = utilcommon.convertImage(im, args, silent=True)
    args.output.write(im.tobytes())

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='convert BMP/PNG to RLE tool')
    parser.add_argument('image', type=argparse.FileType('rb'),
                       help='image file to encode')
    parser.add_argument('-d', '--transparent_palette_index', type=int, default=0xff,
                       help='transparent index for color in palette; default 255')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'), required=True,
                       help='resulting rle')
    parser.add_argument('--quantize', action='store_true', default=False,
                       help='for images not with pal palette; notice: expensive!')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), 
                       help='PAT file for quantize')
    parser.add_argument('-i', '--palette_id',type=int, default=0,
                       help='palette id')
    parser.add_argument('-n', '--night', action='store_true', default=False,
                       help='use night palette')
    parser.add_argument('--dither', action='store_true', default=False,
                       help='whether ditter color when quantizing')

    args = parser.parse_args()
                       
    if args.quantize and args.palette == None:
        print("invalid configuration! quantize must specify palette/id")
    else:
        process()