mkdir libs
platforms=`ls ../src/out`
for p in $platforms;do
    echo "copy $p"
    mkdir libs/$p
    #copy libs
    for i in `find ../src/out/$p -name "lib*.a"`
    do
	echo $i
	cp $i ./libs/$p
    done

    #copy vpx.o
    for i in `find ../src/out/$p/obj/third_party/libvpx/ -name libvpx_intrinsics_*`
    do
	echo $i
	cp $i/*.o ./libs/$p
    done
done



