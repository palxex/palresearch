copy /y sss-mkf-debug3 sss.mkf
copy /y m-msg-debug3 m.msg
copy /y word-dat-debug3 word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > debug3.0.txt