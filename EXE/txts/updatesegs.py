#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import io
import os

lines=[]
with open("segments.txt","rt") as file:
	lines=file.readlines()

# calc offset base on segment 3; since it contains entrypoint
seg3info=lines[4].split('\t')
offset=int(seg3info[2],16)-int(seg3info[1],16)

outlines=[]
outlines.append(lines[0])
for segn in range(1,len(lines)): 
	seginfo=lines[segn].split('\t')
	if len(seginfo)<3:
		continue
	seginfo[2]="%04X"%(int(seginfo[1],16)+offset)
	segline='\t'.join(seginfo)
	outlines.append(segline)

with open("segments.txt","wt") as outf:
	outf.writelines(outlines)