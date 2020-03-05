LL  := latexmk
DEP := $(wildcard *.tex)
MAIN=invc.tex

main: ${DEP}
	${LL} -f -pdf ${MAIN} -auxdir=output -outdir=output

show:
	zathura output/main.pdf
