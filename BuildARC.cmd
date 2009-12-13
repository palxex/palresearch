del research.7z
path E:\cygwin\bin;"C:\Program Files\7-Zip"
find . -iname '*.bak' -exec rm -vf {} ;
find . -iname 'thumbs.db' -exec rm -vf {} ;
find . -iname '#*#' -exec rm -vf {} ;
7z a -t7z -m0=BCJ2 -m1=LZMA:d25:fb255 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3 -mx=9 -ms=200m -mf -mhc -mhcf -mmt -r -x@ignore.list research.7z *