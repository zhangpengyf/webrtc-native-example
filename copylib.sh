for i in `find ../src/out/ -name "lib*.a"`
	do
	echo $i
	cp $i ./libs/
done
