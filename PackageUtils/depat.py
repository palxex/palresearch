#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import sys
import demkf
import utilcommon
from ctypes import *
from PIL import Image, ImageDraw

args=None

def savepalette(palette,fp): #copied from pillow and modified...
    """Save palette to text file.
    """
    if palette.rawmode:
        raise ValueError("palette contains raw palette data")
    if isinstance(fp, str):
        fp = open(fp, "w")
    fp.write("# Palette\n")
    fp.write("# Mode: %s\n" % palette.mode)
    for i in range(256):
        fp.write("%d" % i)
        for j in range(i*len(palette.mode), (i+1)*len(palette.mode)):
            try:
                if sys.version_info[0]<3:
                    fp.write(" %d" % ord(palette.palette[j]))
                else:
                    fp.write(" %d" % palette.palette[j])
            except IndexError:
                fp.write(" 0")
        fp.write("\n")
    fp.close()
    
def process():
    pat = utilcommon.getPalette(args)
    buffer=bytearray(256);
    for i in range(256):
        buffer[i]=i
    im=Image.frombytes("P", (16,16), bytes(buffer))
    im.putpalette(pat)
    
    if args.show:
        im.show(); 
    
    if args.output:
        im.save(args.output)
    if args.savepat:
        savepalette(im.palette,args.output.name+".pat")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for extract PAT')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'),
                       help='resulting bmp')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), required=True, 
                       help='PAT file')
    parser.add_argument('-i', '--palette_id', type=int, default=0,
                       help='palette id')
    parser.add_argument('-n', '--night', action='store_true', default=False,
                       help='use night palette')
    parser.add_argument('--show', action='store_true', default=False,
                       help='show palette png')
    parser.add_argument('--savepat', action='store_true', default=False,
                       help='save pat too')

    args = parser.parse_args()
    if not args.show and args.output == None:
        print("Either Show or Specify output filename")
    else:
        process()