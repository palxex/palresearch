#!/usr/bin/python

import struct
import sys
from glob import glob

if __name__ == "__main__":
	filenames = glob("*.rix")
	for filename in filenames:
		print "processing with %s" % filename
		with open(filename, "rb") as fp:
			rix_data = fp.read()
		if len(rix_data) < 0xC:
			continue
		rhythm_offset, = struct.unpack("<I",rix_data[0xC:0xC+4])
		new_data=rix_data[:rhythm_offset]
		for i in range(0,2): #dup whole rhythms 2 times!
			new_data +=rix_data[rhythm_offset:-2] 
		for i in range(0,11):  # mute all channels
			new_data += struct.pack("<BB",0,0xC0+i)
		for i in range(0,1): 
			new_data += struct.pack("<BB",0,20) # delay time
		new_data += rix_data[-2:]
		with open("duped%s"%filename, "wb") as fp:
			fp.write(new_data)