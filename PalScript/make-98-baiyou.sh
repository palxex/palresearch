#/usr/bin/env sh
cp sss-mkf-98-baiyou sss.mkf
cp m-msg-98-baiyou m.msg
cp word-dat-98-baiyou word.dat
../PackageUtils/demkf.py sss.mkf -p bin
mono script.exe > 98-baiyou.txt
