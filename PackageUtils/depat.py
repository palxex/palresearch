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

def dePAT(patfile,patid=0,day=1):
    pat = demkf.deMKF(patfile,patid)
    if len(pat) == 768 or day:
        pat=pat[0:768]
    else:
        pat=pat[768:1536]
    return "".join([chr(ord(x)*4) for x in pat])
    

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
                fp.write(" %d" % ord(palette.palette[j])) # what the fuck of "%d"%str?
            except IndexError:
                fp.write(" 0")
        fp.write("\n")
    fp.close()
    
def process():
    pat = dePAT(args.palette,args.palette_id,not args.night)
    buffer="".join([chr(x) for x in range(0,256)])
    im=Image.frombytes("P", (16,16), buffer)
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
        print "Either Show or Specify output filename"
    else:
        process()