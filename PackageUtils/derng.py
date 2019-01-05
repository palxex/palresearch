#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import demkf
import deyj1
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw

args=None
length=320*200
ArrayType = c_int16 * length
buffer = ArrayType()

def deRNG(source, prev_frame):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    dll.decoderng(source,c_void_p(addressof(prev_frame)))
    return string_at(prev_frame,length)

def process():
    pat = utilcommon.getPalette(args.palette,args.palette_id)
    frames = []
    memset(buffer,0,length)
    num, = struct.unpack("<I",args.rng.read(4))
    for frame in range(0, num):
        content=demkf.deMKF(args.rng, frame)
        content=deyj1.deYJ1(content)
        bytes = deRNG(content,buffer);
        im = Image.frombytes("P", (320,200), bytes)
        im.putpalette(pat)
        im.info['transparency'] = args.transparent_palette_index
        frames.append(im)
        if args.saveraw:
            open(args.output.name+frame+".raw","wb").write(buffer)
    
    img=Image.new("P", (320,200), args.transparent_palette_index)
    img.save(args.output, save_all=True, append_images=frames, palette=pat, include_color_table=False, duration=args.millisecs_per_frame)
    
    if args.show:
        im.show() 

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for converting RNG to GIF animation')
    parser.add_argument('rng', type=argparse.FileType('rb'),
                       help='rng file to decode')
    parser.add_argument('-o','--output', required=True, type=argparse.FileType('wb'),
                       help='resulting gif')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), required=True, 
                       help='PAT file')
    parser.add_argument('-i', '--palette_id', type=int, default=0,
                       help='palette id')
    parser.add_argument('-d', '--transparent_palette_index', default=0xff,
                       help='transparent index for color in palette; default 255')
    parser.add_argument('-m', '--millisecs_per_frame', type=int, default=100,
                       help='milliseconds per frame; default 100')
    parser.add_argument('--show', action='store_true', default=False,
                       help='show decoded image')
    parser.add_argument('--saveraw', action='store_true', default=False,
                       help='save decoded raw png data')

    args = parser.parse_args()
    process()