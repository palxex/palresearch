#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import re
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw

args=None

def enRLE(indexed_buffer,width,height):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    length=c_int()
    buffer=POINTER(c_byte)()
    dll.encoderlet(indexed_buffer,args.transparent_palette_index,width,width,height,byref(buffer),byref(length))
    return string_at(buffer,length)

def hex2rgb(color):
    color = color.lstrip("#")
    return tuple(
        int(color[idx:idx+2], 16)
        for idx in (0, 2, 4)
    )

def process():
    tcs=[hex2rgb(x) for x in re.findall('#\d{6}',args.transparent_rgb)]
    im=Image.open(args.image)
    (im,ima) = utilcommon.convertImage(im, args)

    if args.save_quantized_png:
        im.save(args.output.name+".quantized.png")
    if args.show:
        im.show()
    if args.quantize:
        for x in range(0,im.width): 
            for y in range(0,im.height):
                c=ima.getpixel((x,y))
                if c[:3] in tcs or (len(c) > 3 and c[3] == 0):
                	im.putpixel( (x,y), args.transparent_palette_index)
    buffer = enRLE(im.tobytes(),im.width,im.height)
    if args.output:
        args.output.write(buffer)
        args.output.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for converting BMP/PNG to RLE')
    parser.add_argument('image', type=argparse.FileType('rb'),
                       help='image file to encode')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'), required=True,
                       help='resulting rle')
    parser.add_argument('-d', '--transparent_palette_index', type=int, default=0xff,
                       help='transparent index for color in palette; default 255')
    parser.add_argument('-t', '--transparent_rgb', default="#ffffff",
                       help='transparent color RGB; default #FFFFFF')
    parser.add_argument('--quantize', action='store_true', default=False,
                       help='for images not with pal palette; notice: expensive!')
    parser.add_argument('-p', '--palette', required=True, type=argparse.FileType('rb'), 
                       help='PAT file for quantize')
    parser.add_argument('-i', '--palette_id',type=int, default=0,
                       help='palette id')
    parser.add_argument('-n', '--night', action='store_true', default=False,
                       help='use night palette')
    parser.add_argument('--dither', action='store_true', default=False,
                       help='whether ditter color when quantizing')
    parser.add_argument('--save_quantized_png', action='store_true', default=False,
                       help='save quantized png')
    parser.add_argument('--show', action='store_true', default=False,
                       help='show quantized png')

    args = parser.parse_args()
                       
    if args.quantize and args.palette == None:
        print("invalid configuration! quantize must specify palette/id")
    else:
        process()