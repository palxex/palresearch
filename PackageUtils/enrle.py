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

def enRLE(indexed_buffer,width,height):
    dll=cdll.LoadLibrary(utilcommon.getPallibPath())
    length=c_int()
    buffer=POINTER(c_byte)()
    dll.encoderlet(indexed_buffer,args.transparent_palette_index,width,width,height,byref(buffer),byref(length))
    return string_at(buffer,length)

def process():
    im=Image.open(args.image)
    if im.mode != "P": 
        if args.quantize == False:
            print "This image have no palette, that implies not a image derle produces; turn on quantize automatically"
            args.quantize=True
        if args.palette == None:
            print "Invalid configuration! quantize must specify palette/id"
            return
    elif 'transparency' in im.info:
        if args.transparent_palette_index != im.info['transparency'] :
            if args.quantize:
                im=im.convert("RGBA")
            else:
                print "bitmap built-in transparency color %d index not same as default %d; is it exported from derle? If not, suggest you rerun encoder with quantize, or color may be terrible" % (im.info['transparency'],args.transparent_palette_index)
                args.transparent_palette_index = im.info['transparency']
    ima=im
    if args.quantize:
        pat = demkf.deMKF(args.palette,args.palette_id)
        if len(pat) > 768: 
            pat=pat[0:768]
        pat="".join([chr(ord(x)*4) for x in pat])
        pat=pat[0:args.transparent_palette_index*3]+"\x00\x00\x00"+pat[args.transparent_palette_index*3+3:]
        imp=Image.new("P",(16,16))
        imp.putpalette(pat)
        im=utilcommon.quantizetopalette(im,imp, 1 if args.dither else 0)

    if args.save_quantized_png:
        im.save(args.output.name+".quantized.png")
    if args.show:
        im.show()
    if args.quantize:
        for x in range(0,im.width): 
            for y in range(0,im.height):
                if im.mode != "P" and ima.getpixel( (x,y) )[3] == 0:
                	im.putpixel( (x,y), args.transparent_palette_index)
    buffer = enRLE(im.tobytes(),im.width,im.height)
    if args.output:
        args.output.write(buffer)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='tool for converting BMP/PNG to RLE')
    parser.add_argument('image', type=argparse.FileType('rb'),
                       help='image file to encode')
    parser.add_argument('-o','--output',type=argparse.FileType('wb'), required=True,
                       help='resulting rle')
    parser.add_argument('-d', '--transparent_palette_index', default=0xff,
                       help='transparent index for color in palette; default 255')
    parser.add_argument('--quantize', action='store_true', default=False,
                       help='for images not with pal palette; notice: expensive!')
    parser.add_argument('-p', '--palette', type=argparse.FileType('rb'), 
                       help='PAT file for quantize')
    parser.add_argument('-i', '--palette_id',type=int, default=0,
                       help='palette id')
    parser.add_argument('--dither', action='store_true', default=False,
                       help='whether ditter color when quantizing')
    parser.add_argument('--save_quantized_png', action='store_true', default=False,
                       help='save quantized png')
    parser.add_argument('--show', action='store_true', default=False,
                       help='show quantized png')

    args = parser.parse_args()
                       
    if args.quantize and args.palette == None:
        print "invalid configuration! quantize must specify palette/id"
    else:
        process()