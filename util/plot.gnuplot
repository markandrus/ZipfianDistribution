#! /bin/sh
gnuplot << EOF

	reset

	set terminal pngcairo size 480,480 enhanced font 'Verdana,12'
	set output "../graphs/$1.png"

	set style line 11 lc rgb '#808080' lt 1
	set border 3 back ls 11
	set tics nomirror
	set style line 12 lc rgb '#808080' lt 0 lw 1
	set grid back ls 12

	set rmargin 4.0
	set title font 'Verdana,16' offset 0,0.5
	set key textcolor rgb '#808080'

	set style line 1 linecolor rgb '#0060ad' linetype 1 linewidth 1 # blue
	set style line 2 linecolor rgb '#dd181f' linetype 2 linewidth 1 # red

	# set title "$1"
	set ylabel "Log Frequency"
	set xlabel "Log Rank"

	set logscale y
	set logscale x

	f(x) = $2/x

	plot "../output/$1.data" u 1:2 title "$1" w lines ls 1, \
	     f(x) title "$2/Rank" ls 2
EOF
