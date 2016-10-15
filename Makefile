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
PDF_OUT = paper.pdf
LITERATURE = bibliography.bib
MARKDOWN_FILES = $(wildcard markdown/*.md)
METADATA_FILE = markdown/meta.yaml
LATEX_EXPAND_SCRIPT = markdown/template/latexpand.pl
PANDOC_TEMPLATE = markdown/template/template.tex

# Output directory
BUILD_DIR = build


# Intermediate tex files
COMBINED_MD = $(BUILD_DIR)/markdown.md
COMBINED_TEX = $(BUILD_DIR)/pandoc-template.combined.tex
MARKDOWN_TEX = $(BUILD_DIR)/markdown.tex

# Derived file names
SRC = $(shell basename $(MARKDOWN_TEX) .tex)
TEX_FILES = $(wildcard preambel/*.tex content/*.tex)
GFX_FILES = $(wildcard graphics/*)

PDF = $(SRC).pdf
AUX = $(SRC).aux

date=$(shell date +%Y%m%d%H%M)

# Builds the document and then watches all markdown files, triggering a
# recompilation when one of the files was modified.
watch: watch-all

# Builds the document and then watches all markdown files, calling `make` with
# e given target when a file changed.
watch-%: pdf
	while inotifywait -e close_write $(MARKDOWN_FILES); do make $@; done

# Builds the document and then watches all markdown files, triggering a
# recompilation when one of the files was modified. Mutes the output of the
# `make` command.
watch-silent: watch-all-silent

	# Builds the document and then watches all markdown files, calling `make` with
	# e given target when a file changed. Mutes the output of the `make` command.
watch-%-silent: pdf
	echo "$0"
	# while inotifywait -e close_write $(MARKDOWN_FILES); do make $@ 1>/dev/null; done

# Default action.
#hier sollte noch der aspell check rein für jedes file einzeln über for schleife
all: $(PDF)
.PHONY: $(PDF)

# Builds the document and outputs it to $(PDF_OUT).
$(PDF): pandoc $(MARKDOWN_TEX) $(LITERATURE) $(TEX_FILES) $(GFX_FILES) create-build-dir
	$(latexmk) -jobname=$(BUILD_DIR)/build $(MARKDOWN_TEX)
	cp $(BUILD_DIR)/build.pdf $(PDF_OUT)

# Cleans all files created during compilation, excluding the final PDF.
clean:
	rm -r $(BUILD_DIR) 2> /dev/null

# Cleans all files created during compilation, including the final PDF.
clean-all: clean
	rem $(PDF_OUT) 2> /dev/null

# Endversion - mit eingebauter Seitenvorschau
# mehrere Durchlaeufe, da bei longtable einige runs mehr vonnoeten sind...
final: $(PDF)
	thumbpdf $(PDF)
	$(pdflatex) -output-directory=$(BUILD_DIR) $(MARKDOWN_TEX)

# Removes all temporary files from the root directory.
mrproper: clean
	rm -f *~

ps: $(PDF)
	pdftops $(PDF)

# Builds the document. Same as `make`.
pdf: $(PDF)

# Creates the build-directory.
create-build-dir:
	mkdir -p $(BUILD_DIR)

# Concatinates all markdown files to one long file that is later fed to pandoc.
concat-markdown: create-build-dir
	sed -s '$$G' $(sort $(MARKDOWN_FILES)) > $(COMBINED_MD)

# Assembles the LaTeX Pandoc template from all its pieces.
pandoc-template: create-build-dir
	$(perl) $(LATEX_EXPAND_SCRIPT) $(PANDOC_TEMPLATE) > $(COMBINED_TEX)

# Converts the concatinated markdown file to tex.
pandoc: create-build-dir pandoc-template concat-markdown
	$(pandoc) $(COMBINED_MD) $(METADATA_FILE) -o $(MARKDOWN_TEX) --template=$(COMBINED_TEX) --bibliography=$(LITERATURE) --chapters

# Builds the document and opens it with $(viewer).
view: pdf
	$(viewer) $(PDF)&

# Opens the document in $(viewer)
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
