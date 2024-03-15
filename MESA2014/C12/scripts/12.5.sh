#! /bin/bash


for d in `seq 0.1 0.1 1`; do
	for n in 50 100 200 500; do
		echo -e "$d\t$n"
		sed -i "5s/.*/$d/" model.dat
		sed -i "4s/.*/2 $n 1000/" model.dat
		evolver 5 model.dat >/dev/null

		sed -i 's/model = .*/model = 0/' baseml.ctl
		baseml baseml.ctl >/dev/null; grep -i lnL mlb | grep "best tree" | awk '{print $NF}' > jc69.$d-$n.lnl
		sed -i 's/model = .*/model = 1/' baseml.ctl
		baseml baseml.ctl >/dev/null; grep -i lnL mlb | grep "best tree" | awk '{print $NF}' > k80.$d-$n.lnl
	done
done



