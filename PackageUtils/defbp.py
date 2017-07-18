#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import argparse
import struct
import os
import demkf
from PIL import Image

def process(f,output,pal,id):
    pat = demkf.deMKF(pal,id)
    if len(pat) > 768:
        pat=pat[0:768]
    pat="".join([chr(ord(x)*4) for x in pat])
    
    im=Image.frombytes("P", (320,200), f.read())
    im.putpalette(pat)
    
    #im.show(); //uncomment it to view
    im.save(output)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='convert FBP to palette BMP tool')
    parser.add_argument('fbp', type=argparse.FileType('rb'),
                       help='FBP file to decode')
    parser.add_argument('bmp',type=argparse.FileType('wb'),
                       help='resulting bmp')
    parser.add_argument('--palette', '-p', type=argparse.FileType('rb'), required=True, 
                       help='PAT file')
    parser.add_argument('--patid', '-i', type=argparse.FileType('rb'), default=0,
                       help='PAT file')

    args = parser.parse_args()
    process(args.fbp,args.bmp,args.palette,args.patid)