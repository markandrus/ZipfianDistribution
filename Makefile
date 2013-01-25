all:
	for f in "English" "EnglishPhonemes" "Dutch" "Voynich"; do \
		runhaskell Main.hs input/$$f.dx1 > output/$$f.data; done
	cd util && ./makePlots.sh
