copy /y sss-mkf-2.1 sss.mkf
copy /y m-msg-2.x m.msg
copy /y word-dat-2.x word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > dream2.1.txt