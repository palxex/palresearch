cp sss-mkf-debug3 sss.mkf
cp m-msg-debug3 m.msg
cp word-dat-debug3 word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > debug3.0.txt