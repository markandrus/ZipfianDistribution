ZipfianDistribution
===================

Assignment #2 for my Computational Linguistics Class

Calculated Zipf Constants
-------------------------

Assume the frequency of a word `freq(w)` is equal to some language-specific
constant `Z` divided by the rank of said word `rank(w)`. What are the average
values of `Z`, or the "Zipf Constants", of English, Dutch, and the Voynich
manuscript?

| Language | Average Zipf Constant |
|----------|-----------------------|
| English  | 0.9047531             |
| Dutch    | 0.95159626            |
| Voynich  | 0.860046              |

The English and Dutch files have an average Zipf Constant closer to 1 than the
Voynich manuscript, implying a closer inverse relationship between frequency and
rank than in the Voynich manuscript. However, the Voynich manuscript file
represents a relatively small sample size compared to the English and Dutch
files used. With more samples of the supposed "language" the Voynich manuscript
is written in, we might see its Zipf Constant approach 1.

Graphs
------

See `graphs` for more.

### Languages

<p align="center">
	<img src="https://raw.github.com/markandrus/ZipfianDistribution/master/graphs/All.png">
</p>

### Phonemes

English phonemes are not quite Zipfian: my calculations yielded a Zipf Constant
of 0.22214584). They are better approximated by the Yule Equation (see
[Phoneme Frequencies Follow a Yule Distribution](http://www.skase.sk/Volumes/JTL09/pdf_doc/1.pdf)
by Yuri Tambovtsev and Colin Martindale for more).

<p align="center">
	<img src="https://raw.github.com/markandrus/ZipfianDistribution/master/graphs/EnglishPhonemes.png">
</p>

Filtering the Data
------------------

Filtering high-rank words should move the Zipf Constant for any of the above
languages closer to 1. We could choose our threshold by maximizing `Z`.

In our English sample, the long tail begins to deviate from the Zipfian
Distribution. Filtering low frequency words should bring `Z` closer in this
case.
