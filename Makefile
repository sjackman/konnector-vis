# Test abyss-connectpairs

# Parameters
ref=g1000
j=2
k=20
b=10000

# Phony targets

all: e0_merged.fa \
	e0.001_merged.fa \
	e0.002_merged.fa \
	e0.005_merged.fa

.PHONY: all
.DELETE_ON_ERROR:
.SECONDARY:

# Rules

$(ref).fa:
	curl https://raw.github.com/dzerbino/velvet/master/data/$(ref).fa \
		|abyss-tofastq --fasta >$@

e%_1.fq e%_2.fq: $(ref).fa
	wgsim -S 0 -e $* -N 200 -r 0 -R 0 $< e$*_1.fq e$*_2.fq

%_merged.fa: %_1.fq %_2.fq
	time abyss-connectpairs -j$j -v -k$k -b$b $^ -o $*
