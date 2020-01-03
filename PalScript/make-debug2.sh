cp sss-mkf-debug2 sss.mkf
cp m-msg-debug2 m.msg
cp word-dat-debug2 word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > debug2.0.txt