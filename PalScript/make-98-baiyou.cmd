copy /y sss-mkf-98-baiyou sss.mkf
copy /y  m-msg-98-baiyou m.msg
copy /y word-dat-98-baiyou word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > 98-baiyou.txt
