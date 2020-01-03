cp sss-mkf-3.1 sss.mkf
cp m-msg-debug3 m.msg
cp word-dat-debug3 word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > debug3.1.txt