#!/usr/bin/env python
# -*- coding: utf-8 -*-  
import platform

def getOSDynamicLibraryExtension():
    os = platform.system()
    switcher = {
        "Windows": "DLL",
        "Darwin": "dylib"
    }
    return switcher.get(os, "so")
