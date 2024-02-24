#!/usr/bin/env python3
# -*- coding: utf-8 -*-  
from __future__ import print_function
import platform
import os
import sys
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
    return (os.path.dirname(sys.argv[0]) if sys.argv[0] else ".") +"/../PalLibrary/libpallib."+getOSDynamicLibraryExtension()

def PallibExist():
    return os.path.isfile(getPallibPath())

def getPalette(args):
    pat = bytearray(demkf.deMKF(args.palette, args.palette_id))
    if len(pat) > 768 and args.night:
        pat=pat[768:1536]
    else:
        if args.night:
            print("this palette index does not have a night alternative, turns to day")
        pat=pat[0:768]
    for i in range(0,len(pat)):
        pat[i]=pat[i]*4
    return bytes(pat)
    
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
    imnew = Image.new('P',silf.size)
    imnew.im = im
    imnew.putpalette(palette.palette.tobytes())
    im = imnew
    return im

def convbytes(str):
    if sys.version_info[0]<3:
        return bytes(str)
    else:
        return bytes(str,"ascii")

def convertImage(im, args, silent=False):
    if im.mode != "P":
        if args.quantize == False:
            print("This image have no palette, that implies not a image derle produces; turn on quantize automatically")
            args.quantize=True
        if im.mode != "RGBA" and args.quantize:
            print(f"input image not RGBA(was {im.mode}), convert to RGBA")
            im=im.convert("RGBA")
        if args.palette == None:
            print("Invalid configuration! quantize must specify palette/id")
            return
    elif 'transparency' in im.info:
        info=im.info
        if args.quantize:
            im=im.convert("RGBA")
        elif args.transparent_palette_index != info['transparency']:
            if not silent:
                print("input image built-in transparency color %d index not same as default %d; is it exported from derle? If not, suggest you rerun encoder with quantize, or color may be terrible" % (info['transparency'],args.transparent_palette_index))
            args.transparent_palette_index = info['transparency']
    else: #P but no transparency
        if args.quantize:
            im=im.convert("RGBA")
        elif not silent:
            print("input image not specified transparency color; it must not be exported from derle. Suggestion: rerun encoder with quantize, or color will be terrible")

    ima=im
    if args.quantize:
        pat = getPalette(args)
        pat=pat[0:args.transparent_palette_index*3]+bytearray(convbytes("\x00\x00\x00"))+pat[args.transparent_palette_index*3+3:]
        imp=Image.new("P",(16,16))
        imp.putpalette(pat)
        im=quantizetopalette(im,imp, 1 if args.dither else 0)
    return (im,ima)

def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█'):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print('\r%s |%s| %s%% %s' % (prefix, bar, percent, suffix), end = '\r')
    # Print New Line on Complete
    if iteration == total: 
        print()

def is_input_dir(folder):
    if os.path.isdir(folder):
        return folder
    else:
        raise NotADirectoryError(folder)

def is_output_dir(folder):
    if os.path.isdir(folder):
        return folder
    else:
        os.mkdir(folder)
        return folder
