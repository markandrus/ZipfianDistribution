#! /bin/sh
gnuplot << EOF
	set title "$1, $2 and $3"

	set terminal png
	set output "/dev/null"

	set ylabel "Log Frequency"
	set xlabel "Log Rank"
	set logscale x
	set logscale y

	# plot "../output/$1.data" u 1:4 notitle, f(x) notitle
	plot "../output/$1.data" u 1:2 title "$1" w lines, \
		"../output/$2.data" u 1:2 title "$2" w lines, \
		"../output/$3.data" u 1:2 title "$3" w lines
	# set arrow from GPVAL_X_MIN,GPVAL_Y_MIN to GPVAL_X_MAX,GPVAL_X_MAX*(1+log($2)) nohead lc rgb 'green'

	set output "../graphs/All.png"

	replot
EOF
