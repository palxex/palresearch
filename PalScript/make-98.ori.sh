cp sss-mkf-98-ori sss.mkf
cp m-msg-98-ori m.msg
cp word-dat-98-ori word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > 98.ori.txt