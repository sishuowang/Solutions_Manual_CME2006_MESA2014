#! /bin/bash


###############################################
nsim=100
trees=(1.tre 2.tre 3.tre)
model=K80
iqtree=iqtree
mpboot=mpboot
CAL=~/project/Yang/scripts/cal_partition_dist.R


###############################################
for tree in ${trees[@]}; do
	count_ml=0; count_ml2=0; count_mp=0
	echo $tree
	for i in `seq $nsim`; do
		tree_str=`cat $tree`
		sed -i "7s/.*/$tree_str/" model.dat
		evolver 5 model.dat >/dev/null

		mpboot -st DNA -s mc.txt -pre mp >/dev/null
		if [ `Rscript $CAL mp.treefile $tree` == "T" ]; then
			count_mp=$(($count_mp+1))
		fi

		iqtree -st DNA -s mc.txt -m $model -pre ml -quiet -redo
		if [ `Rscript $CAL ml.treefile $tree` == "T" ]; then
			count_ml=$(($count_ml+1))
		fi

		iqtree -st DNA -s mc.txt -m JC69 -pre ml -quiet -redo
		if [ `Rscript $CAL ml.treefile $tree` == "T" ]; then
			count_ml2=$(($count_ml2+1))
		fi
	done
	echo -e "$count_mp\t$count_ml\t$count_ml2"
done


