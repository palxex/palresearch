del research.7z
del /s /q *.bak
del /s /q thumbs.db
path %PATH%;"C:\Program Files\7-Zip"
7z a -t7z -mx=9 -ms -mf -mhc -mhcf -mmt -r -x@ignore.list research.7z *