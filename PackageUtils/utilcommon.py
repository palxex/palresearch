#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import platform
import os
import demkf
from PIL import Image

def getOSDynamicLibraryExtension():
    _os = platform.system()
    switcher = {
        "Windows": "DLL",
        "Darwin": "dylib"
    }
    return switcher.get(_os, "so")
    
def getPallibPath():
    return (os.path.dirname(__file__)+"/" if __file__ else "") +"../PalLibrary/libpallib."+getOSDynamicLibraryExtension()

def PallibExist():
    return os.path.isfile(getPallibPath())

def getPalette(palette_file, palette_id):
    pat = demkf.deMKF(palette_file, palette_id)
    if len(pat) > 768:
        pat=pat[0:768]
    pat="".join([chr(ord(x)*4) for x in pat])
    return pat
    
def quantizetopalette(silf, palette, dither=False):
    """Convert an RGB or L mode image to use a given P image's palette."""
    silf.load()

    # use palette from reference image
    palette.load()
    if palette.mode != "P":
        raise ValueError("bad mode for palette image")
    if  silf.mode != "RGBA" and silf.mode != "RGB" and silf.mode != "L" and silf.mode != "P":
        raise ValueError(
            "only RGB/A or L/P mode images can be quantized to a palette! this mode:%s" % silf.mode
            )
    im = silf.im.convert("P", 1 if dither else 0, palette.im)
    return silf._makeself(im)

def convertImage(im, args):
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
                print "input PNG built-in transparency color %d index not same as default %d; is it exported from derle? If not, suggest you rerun encoder with quantize, or color may be terrible" % (im.info['transparency'],args.transparent_palette_index)
                args.transparent_palette_index = im.info['transparency']
    else: #P but no transparency
        if args.quantize:
            im=im.convert("RGBA")
        else:
            print "input PNG not specified transparency color; it must not be exported from derle. Suggestion: rerun encoder with quantize, or color will be terrible"

    ima=im
    if args.quantize:
        pat = demkf.deMKF(args.palette,args.palette_id)
        if len(pat) > 768:
            pat=pat[0:768]
        pat="".join([chr(ord(x)*4) for x in pat])
        pat=pat[0:args.transparent_palette_index*3]+"\x00\x00\x00"+pat[args.transparent_palette_index*3+3:]
        imp=Image.new("P",(16,16))
        imp.putpalette(pat)
        im=quantizetopalette(im,imp, 1 if args.dither else 0)
    return (im,ima)
