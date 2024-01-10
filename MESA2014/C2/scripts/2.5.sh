#! /bin/bash


################################################
n=1000
n_codons=(100 200 300 500 1000)
#n_codons=(50 100 200 300 500 1000)


################################################
for n_codon in ${n_codons[@]}; do
	echo -e "# of codons:\t$n_codon"
	[ -f deltaLL$n_codon.list ] && rm deltaLL$n_codon.list
	for i in `seq $n`; do
		mod=`echo "$i%100"|bc`
		[ $mod == 1 ] && echo $i >&2
		length=`expr 3 \* $n_codon`
		iqtree --alisim alignment_codon -m 'MG2K{1,2}+FQ' --length $length -t tree.nwk -af phy -quiet
		# omega to be estimated
		sed -i 's/fix_omega.*/fix_omega = 0/' codeml.ctl
		codeml >/dev/null
		lnl1=`grep -P 'lnL' mlc | awk '{print $(NF-1)}'`
		# omega fixed as 1.0
		sed -i 's/fix_omega.*/fix_omega = 1/' codeml.ctl
		codeml >/dev/null
		lnl0=`grep -P 'lnL' mlc | awk '{print $(NF-1)}'`
		echo "scale=2; 2 * ($lnl1 - $lnl0)" | bc
	done > deltaLL$n_codon.list
	echo
done
