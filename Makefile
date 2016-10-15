# Executables
latexmk = latexmk
pandoc = pandoc
perl = perl

## Required for thumbpdf as latexmk does not support thumbpdf by itself
pdflatex = pdflatex

## evince at linux
viewer = 'C:/Program Files (x86)/SumatraPDF/SumatraPDF.exe'

## Editor
editor = gedit


# Main file name
MASTER_TEX = ausarbeitung.tex
LITERATURE = bibliography.bib
MARKDOWN_FILES = $(wildcard markdown/*.md)
METADATA_FILE = markdown/meta.yaml
LATEX_EXPAND_SCRIPT = markdown/template/latexpand.pl
PANDOC_TEMPLATE = markdown/template/template.tex

# Output directory
BUILD_DIR = build


# Derived file names
SRC = $(shell basename $(MASTER_TEX) .tex)
TEX_FILES = $(wildcard preambel/*.tex content/*.tex)
GFX_FILES = $(wildcard graphics/*)

PDF = $(SRC).pdf
AUX = $(SRC).aux

# Intermediate tex files
COMBINED_MD = $(BUILD_DIR)/markdown.md
COMBINED_TEX = $(BUILD_DIR)/pandoc-template.combined.tex
MARKDOWN_TEX = $(BUILD_DIR)/markdown.tex

date=$(shell date +%Y%m%d%H%M)

# was wird gemacht, falls nur make aufgerufen wird
#hier sollte noch der aspell check rein für jedes file einzeln über for schleife
all: $(PDF)
.PHONY: $(PDF)

$(PDF): $(MASTER_TEX) $(LITERATURE) $(TEX_FILES) $(GFX_FILES) create-build-dir
	$(latexmk) -jobname=$(BUILD_DIR)/build $(MASTER_TEX)
	cp $(BUILD_DIR)/build.pdf $(PDF)

clean:
	rm -r $(BUILD_DIR)

# Endversion - mit eingebauter Seitenvorschau
# mehrere Durchlaeufe, da bei longtable einige runs mehr vonnoeten sind...
final: $(PDF)
	thumbpdf $(PDF)
	$(pdflatex) -output-directory=$(BUILD_DIR) $(MASTER_TEX)

mrproper: clean
	rm -f *~

ps: $(PDF)
	pdftops $(PDF)

pdf: $(PDF)

create-build-dir:
	mkdir -p $(BUILD_DIR)

concat-markdown: create-build-dir
	sed -s '$$G' $(sort $(MARKDOWN_FILES)) > $(COMBINED_MD)

pandoc-watch:
	while inotifywait -e close_write $(MARKDOWN_FILES); do make pandoc; done

pandoc-template: create-build-dir
	$(perl) $(LATEX_EXPAND_SCRIPT) $(PANDOC_TEMPLATE) > $(COMBINED_TEX)

pandoc: create-build-dir pandoc-template concat-markdown
	$(pandoc) $(COMBINED_MD) $(METADATA_FILE) -o $(MARKDOWN_TEX) --template=$(COMBINED_TEX) --bibliography=$(LITERATURE) --chapters
	$(MAKE) MASTER_TEX=$(MARKDOWN_TEX)

view: pdf
	$(viewer) $(PDF)&

edit:
	$(viewer) $(PDF)&
	$(editor) *.tex&

6: ps
	psnup -6 $(SRC).ps > 6.ps

stand: $(PDF)
	cp $(PDF) "Ausarbeitung - Stand $(date).pdf"

standps: ps
	psnup -2 $(SRC).ps > "Ausarbeitung - Stand $(date).ps"

##
# Das ganze am Besten vor der final und als eigene Version ala make spellcheck
# aspell line: aspell -t -l de_DE -d german -c --per-conf= "Dateiname" *.tex -T utf-8 --encoding=utf-8
# Schreiben der LaTeX-Befehle in eine config Dateiname. Sieht so aus
# add-tex-command begin PO // PO := prüfe []{} ;; po := ignoriere []{}
# Leerzeichen ungleich Tabs !!!
# Config File nicht vergessen
aspell:
	for tex in $(TEX_FILES);	\
		do	\
			aspell -t -l de_DE -d german -T utf-8 -c $$tex --encoding=utf-8;	\
		done
#
##

showundef:
	grep undefined $(LOG)

html: clean pdf
	rm $(AUX)
	htlatex $(SRC) "html,word,charset=utf8" " -utf8"
