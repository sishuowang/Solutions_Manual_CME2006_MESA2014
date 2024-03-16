for i in 0.1 0.3 0.5 1 1.5 2 3; do
	echo $i
	sed "/tree length/s/^[^ ]\+/$i/" -i MCcodon.dat
	evolver 6 MCcodon.dat >/dev/null
	codeml >/dev/null
	grep omega mlc | awk '{print $NF}' > omega-$i.list
	echo
done
