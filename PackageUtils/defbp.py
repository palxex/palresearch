#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import utilcommon
from PIL import Image

def process(args):
    pat = utilcommon.getPalette(args)
    
    im=Image.frombytes("P", (320,200), args.fbp.read())
    im.putpalette(pat)
    
    if args.show:
        im.show()
    if args.output:
        im.save(args.output)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='convert FBP to palette BMP tool')
    parser.add_argument('fbp', type=argparse.FileType('rb'),
                       help='FBP file to decode')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'),
                       help='resulting bmp')
    parser.add_argument('--palette', '-p', type=argparse.FileType('rb'), required=True, 
                       help='PAT file')
    parser.add_argument('--palette_id', '-i', type=argparse.FileType('rb'), default=0,
                       help='PAT file')
    parser.add_argument('-n', '--night', action='store_true', default=False,
                       help='use night palette')
    parser.add_argument('--show', action='store_true', default=False,
                       help='show decoded image')

    args = parser.parse_args()
    process(args)