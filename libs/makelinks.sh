ALL=""
for i in `ls lib*.a`
do
	ALL="$ALL -l$i"
done
for i in `ls *.stamp`
do
    ALL="$ALL -l$i"
done

echo $ALL
