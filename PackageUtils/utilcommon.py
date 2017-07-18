#!/usr/bin/env python2
# -*- coding: utf-8 -*-  
import platform
import os
from PIL import Image

def getOSDynamicLibraryExtension():
    _os = platform.system()
    switcher = {
        "Windows": "DLL",
        "Darwin": "dylib"
    }
    return switcher.get(_os, "so")
    
def getPallibPath():
    return os.path.dirname(__file__)+"/../PalLibrary/libpallib."+getOSDynamicLibraryExtension()

def PallibExist():
    return os.path.isfile(getPallibPath())
    
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
