cp sss-mkf-2.0 sss.mkf
cp m-msg-2.x m.msg
cp word-dat-2.x word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > dream2.0.txt