copy /y sss-mkf-3.1 sss.mkf
copy /y m-msg-debug3 m.msg
copy /y word-dat-debug3 word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > debug3.1.txt