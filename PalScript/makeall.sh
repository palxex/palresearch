for i in `ls make-*.sh`
do 
    echo "invoking $i"
    source $i
done