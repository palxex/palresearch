cp sss-mkf-original sss.mkf
cp m-msg-original m.msg
cp word-dat-original word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > dos.original.txt