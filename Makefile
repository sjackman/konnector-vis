# Test abyss-connectpairs

# Parameters
j=2
k=20
g=100e3

# Phony targets

all: e0-connected.fa \
	e0.001-connected.fa \
	e0.002-connected.fa \
	e0.005-connected.fa

.PHONY: all
.DELETE_ON_ERROR:
.SECONDARY:

# Rules

test_reference.fa:
	curl https://raw.github.com/dzerbino/velvet/master/data/test_reference.fa \
		|abyss-tofastq --fasta >$@

e%_1.fq e%_2.fq: test_reference.fa
	wgsim -S 0 -e $* -N 25000 -r 0 -R 0 $< e$*_1.fq e$*_2.fq

%-connected.fa: %_1.fq %_2.fq
	time abyss-connectpairs -j$j -v -k$k -g$g $^ >$@
