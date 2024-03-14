#! /bin/bash


###############################################
d=`dirname $0`
PROG=$d/get_bl_CI_interval.rb

minmax_arg=""
multiply_arg=""
is_ci=false
format=''
is_header=false
exclude_list=''


###############################################
figtree_file=$1


###############################################
while [ $# -gt 0 ]; do
	case $1 in
		-i)
			figtree_file=$2
			shift
			;;
		--minmax)
			minmax_arg="--minmax"
			;;
		--multiply)
			multiply_arg="--multiply $2"
			shift
			;;
		--ci|--CI)
			is_ci=true
			;;
		--format|-f)
			format=$2
			;;
		--header)
			is_header=true
			;;
		--exclude_list)
			exclude_list=$2
			shift
			;;
	esac
	shift
done


###############################################
if [ -z $format ]; then
	echo "--format (mcmctree or revbayes) has to be specified! Exiting ......" >&2
	echo ""
	exit 1
fi


###############################################
if [ $is_header == true ]; then
	if [ $minmax_arg == "--minmax" ]; then
		echo -e "node\tage\tmin\tmax"
	else
		echo -e "node\tage\tinterval"
	fi
fi

if [ "$is_ci" == true ]; then
	minmax_arg=''
fi

case $format in
	mcmctree)
		SED=$d/figtree_mcmctree_reformat.sed
		;;
	revbayes)
		SED=$d/figtree_revbayes_reformat.sed
		#sed -f $d/figtree_revbayes_reformat.sed $figtree_file | ruby $PROG -i - $minmax_arg $multiply_arg
		;;
esac

if [ -f "$exclude_list" ]; then
	sed -f $SED $figtree_file | nw_prune -f - $exclude_list | ruby $PROG -i - $minmax_arg $multiply_arg
else
	sed -f $SED $figtree_file | ruby $PROG -i - $minmax_arg $multiply_arg
fi
