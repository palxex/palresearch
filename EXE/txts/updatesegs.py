#!/usr/bin/env python
# -*- coding: utf-8 -*-
import io
import os

lines=io.open("segments.txt","rt").read().split(os.linesep)
outf=io.open("tmp","wt",newline=os.linesep)

# calc offset base on segment 3; since it contains entrypoint
seg3info=lines[4].split('\t')
offset=int(seg3info[2],16)-int(seg3info[1],16)
offhex="%x"%offset

outf.write(lines[0]+os.linesep)
for segn in range(1,len(lines)): 
	seginfo=lines[segn].split('\t')
	if len(seginfo)<3:
		continue
	seginfo[2]="%x"%(int(seginfo[1],16)+offset)
	segline='\t'.join(seginfo)
	outf.write(segline+os.linesep)

os.rename("tmp", "segments.txt")