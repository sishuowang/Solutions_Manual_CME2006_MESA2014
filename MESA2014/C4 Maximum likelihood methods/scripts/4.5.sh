#! /bin/bash


model=JC69

#iqtree -redo -s rbcL.nogaps_amb.fas -te vegetables.nwk -m $model -quiet

#iqtree --alisim sim -m $model -te rbcL.nogaps_amb.fas.treefile -st DNA -af fasta -quiet --length 1312

evolver 5 JC69.dat >/dev/null

python nexus2fasta.py mc.nex sample.fasta >/dev/null

iqtree -s sample.fasta -m $model -te vegetables.nwk -redo -quiet

lnl=`grep "Optimal log-likelihood" sample.fasta.log | awk '{print $NF}'`

lnl_max=`Rscript 4.5.R sample.fasta 2>/dev/null`

echo "scale=2; $lnl_max - $lnl" | bc

