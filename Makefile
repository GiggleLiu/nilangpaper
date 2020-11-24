%.tex: %.bnf
	python mkbnf.py $< $@

all: ./nilangcore.tex
	