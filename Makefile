# Test ABySS-Konnector

# Parameters
ref=g1000
j=2
k=20
b=2000

# Phony targets

all: e0.001_one.ccomp.neato.png

.PHONY: all
.DELETE_ON_ERROR:
.SECONDARY:

# Rules

e%_1.fq e%_2.fq: $(ref).fa
	wgsim -S 0 -e $* -N 200 -r 0 -R 0 $< e$*_1.fq e$*_2.fq

%_merged.fa: %_1.fq %_2.fq
	time konnector -j$j -v -k$k -b$b $^ -o $*

stats.tsv: e0_merged.fa e0.001_merged.fa e0.002_merged.fa e0.005_merged.fa
	abyss-fac $^ >$@

%.tsv.md: %.tsv
	abyss-tabtomd $< >$@

# Construct a Blooom filter
%.bloom: %_1.fq %_2.fq
	abyss-bloom build -v -k$k -b$b -l2 $@ $^

# Take the first read of two FASTQ files
%_one.fq: %_1.fq %_2.fq
	(head -n4 $*_1.fq && head -n4 $*_2.fq) >$@

# Connect one read using a preconstructed Bloom filter
%_one_merged.fa %_one_d.gv: %.bloom %_one.fq
	konnector -v -k$k -i $< -d $*_one_d.gv -o $*_one $*_one.fq
	sed -i '' 's/^digraph.*/digraph g {/' $*_one_d.gv

%_one_fp.gv: %_one_d.gv
	gvpr 'E[head.color=="gray"]' $< >$@

# Create a de Bruijn graph from a FASTA file
%.fa.gv: %.fa
	farc -f1 -r2 $< |./debruijngraph -k$k >$@

# Create a de Bruijn graph from a FASTQ file
%.fq.gv: %.fq
	sed -n 's/^@/>/p;n;p;n;n' $< |farc -ff -rr |./debruijngraph -k$k >$@

# Colour a graph black
%.black.gv: %.gv
	gvpr 'N{color="black"} E[1]' $< >$@

# Colour a graph blue
%.blue.gv: %.gv
	gvpr 'N{color="blue"} E[1]' $< >$@

# Colour a graph green
%.green.gv: %.gv
	gvpr 'N{color="green"} E[1]' $< >$@

# Colour a graph red
%.red.gv: %.gv
	gvpr 'N{color="red"} E[1]' $< >$@

# Colour a graph orange
%.orange.gv: %.gv
	gvpr 'N{color="orange"} E[1]' $< >$@

# Merge graphs
%_one.gv: %_one_fp.orange.gv %_1.fq.red.gv $(ref).fa.black.gv %_one_merged.fa.blue.gv %_one.fq.green.gv
	(echo 'strict digraph g { \
		graph[splines=none] \
		node[shape=point] \
		edge[len=0.01]'; \
		sed -E '/^digraph|^}/d' $^; \
		echo '}') >$@

%.ccomp.gv: %.gv
	-gvpr -i 'N[color!="black"]' $< |ccomps -zX'#0' >$@

# Render a graph using dot
%.dot.png: %.gv
	dot -Tpng -o $@ $<

# Render a graph using neato
%.neato.png: %.gv
	neato -Tpng -o $@ $<
