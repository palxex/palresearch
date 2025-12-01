copy /y sss-mkf-debug2 sss.mkf
copy /y m-msg-debug2 m.msg
copy /y word-dat-debug2 word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > debug2.0.txt