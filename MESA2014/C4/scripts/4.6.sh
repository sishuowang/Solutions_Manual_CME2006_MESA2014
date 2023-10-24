#! /bin/bash

# IQ-Tree
mkdir iqtree
cd iqtree
for m in JC69 K80 HKY85 GTR JC69+G5 K80+G5 HKY85+G5 GTR+G5; do
	echo $m
	iqtree -redo -m $m -pre $m -s ../rbcL.nogaps_amb.fas -quiet
done
cd ..

# raxml-ng
mkdir raxml-ng
cd raxml-ng
for m in JC K80 HKY GTR JC+G5 K80+G5 HKY+G5 GTR+G5; do
	echo $m
	raxml-ng --redo --msa ../rbcL.nogaps_amb.fas --model $m --prefix $m
done
cd ..
