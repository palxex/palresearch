copy /y sss-mkf-original sss.mkf
copy /y m-msg-original m.msg
copy /y word-dat-original word.dat
py ../PackageUtils/demkf.py sss.mkf -p bin
script > dos.original.txt