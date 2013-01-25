#! /bin/sh
gnuplot << EOF
	set title "$1"

	set terminal png
	set output "/dev/null"

	# g(x) = f(x) + x**b
	# fit g(x) '../output/$1.data' u 1:2 via b

	set ylabel "Log Frequency"
	set xlabel "Log Rank"
	set logscale y
	set logscale x

	f(x) = $2/x

	plot "../output/$1.data" u 1:2 notitle w lines, \
		f(x) title "$2 / Rank"

	set output "../graphs/$1.png"

	replot
EOF
