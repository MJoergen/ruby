names  = løsning.tex
tex_pdfs   = $(names:.tex=.pdf)

all: $(tex_pdfs)

%.pdf : %.tex
	latexmk -pdf $<

clean:
	rm -f *.log *.aux *.pdf *.pre *.toc *.fdb_latexmk *.fls

