#! /bin/sh
for f in "English 0.9047531" "Dutch 0.95159626" "Voynich 0.860046"
do
	./plot.gnuplot $f
done

./multiplot.gnuplot English Dutch Voynich

./plot.gnuplot EnglishPhonemes 0.22214584
