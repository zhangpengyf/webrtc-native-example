for i in `find ../src/out/ -name "*.lib"`
	do
	echo $i
	cp $i ./libs/
done