echo "Unimplemented methods:"
requests=`grep 'request :' ../compute.rb |awk -F : '{print $2".rb"}'`
for f in $requests; do
    if [ ! -f "compute/$f" ]; then 
        echo $f; 
    fi
done

echo
echo
echo "Useless files:"

for f in `find compute -type f`; do
    f=`echo $f|cut -d '/' -f 2`
    found=0
    for s in $requests; do
        if [ $f = $s ]; then 
            found=1
            break
        fi
    done
    [ $found -eq 0 ] && echo $f
done
