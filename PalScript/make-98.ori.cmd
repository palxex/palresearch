copy /y sss-mkf-98-ori sss.mkf
copy /y m-msg-98-ori m.msg
copy /y word-dat-98-ori word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > 98.ori.txt