###  name:      	Makefile
###  synopsis:  	Build `synthslant' style file and documentation
###  author:    	Dr. Christoph L. Spiel
###  GNU make version:  4.3


SHELL := /bin/sh


BASE64 := base64
BASE64_FLAGS :=


DVIPDFMX := dvipdfmx
DVIPDFMX_FLAGS :=


DVIPS := dvips
DVIPS_FLAGS := -d1 # debug \special{}


LATEX_PROPER := pdflatex
LATEX := /usr/bin/env max_print_line=2147483647 $(LATEX_PROPER)
LATEX_FLAGS := -file-line-error -halt-on-error -interaction=nonstopmode -output-directory=.
LATEX_RERUN_TRIGGER := '^Package rerunfilecheck Warning: File [^ ]* has changed'
LATEX_WARNING := '^LaTeX (|[A-Za-z0-9_]* )Warning:'


MAKEINDEX := makeindex
MAKEINDEX_FLAGS := -q


METAPOST := mpost
METAPOST_FLAGS := -file-line-error -interaction=nonstopmode -tex=latex


PROJECT_NAME := synthslant
SOURCE_FILES := LICENSE Makefile README.md synthslant.dtx synthslant.ins
DOCUMENTATION_FILES := synthslant-gauge.pdf synthslant.pdf



.PHONY: all
all: sty pdf


.PHONY: sty
sty: synthslant.sty


.PHONY: pdf
pdf: doc gauge test


.PHONY: doc
doc: synthslant.pdf


.PHONY: gauge
gauge: synthslant-gauge.pdf


.PHONY: test
test: synthslant-minimal-test.pdf


export TEMPORARY_DIRECTORY


.PHONY: dist
dist:
	$(eval TEMPORARY_DIRECTORY := $(shell mktemp -d))
	trap '$(RM) -r $(TEMPORARY_DIRECTORY); exit 1' HUP INT QUIT TERM;  $(MAKE) __dist
	$(RM) -r $(TEMPORARY_DIRECTORY)


.PHONY: __dist
__dist: LATEX_FLAGS += -interaction=batchmode
__dist: $(DOCUMENTATION_FILES)
	test -d '$(TEMPORARY_DIRECTORY)'
	test -w '$(TEMPORARY_DIRECTORY)'
	mkdir $(TEMPORARY_DIRECTORY)/$(PROJECT_NAME)
	cp $(SOURCE_FILES) $(TEMPORARY_DIRECTORY)/$(PROJECT_NAME)
	mkdir $(TEMPORARY_DIRECTORY)/$(PROJECT_NAME)/docs
	cp $(DOCUMENTATION_FILES) $(TEMPORARY_DIRECTORY)/$(PROJECT_NAME)/docs
	tar czf $(PROJECT_NAME).tar.gz -C $(TEMPORARY_DIRECTORY) $(PROJECT_NAME)


.PHONY: distcheck
distcheck: LATEX_FLAGS += -interaction=batchmode
distcheck: dist
	$(eval TEMPORARY_DIRECTORY := $(shell mktemp -d))
	test -d '$(TEMPORARY_DIRECTORY)'
	test -w '$(TEMPORARY_DIRECTORY)'
	tar xzf $(PROJECT_NAME).tar.gz -C $(TEMPORARY_DIRECTORY)
	$(MAKE) --directory=$(TEMPORARY_DIRECTORY)/$(PROJECT_NAME) LATEX_FLAGS='$(LATEX_FLAGS)' all
	$(RM) -r $(TEMPORARY_DIRECTORY)
	@printf '\n\ndistcheck passed.\n'


.PHONY: clean
clean:
	$(RM) ./*.aux ./*.brf ./*.dvi ./*.glg ./*.glo ./*.gls
	$(RM) ./*.hd ./*.idx ./*.ilg ./*.ind ./*.loe ./*.lof ./*.log ./*.lot
	$(RM) ./*.mp ./*.mps ./*.mpx ./*.out ./*.pdf ./*.ps ./*.toc
	$(RM) mptextmp.* mpxerr.tex
	$(RM) README README.html RELEASE-HOWTO RELEASE-HOWTO.html
	$(RM) compare-with-the-gimp.eps compare-with-the-gimp.png
	$(RM) $(PROJECT_NAME).tar.gz


.PHONY: mostlyclean
mostlyclean: clean


.PHONY: maintainer-clean
maintainer-clean: mostlyclean
	$(RM) ./*.base64 ./*.gst ./*.ist ./*.mp ./*.sty ./*.tex


.PHONY: perf
perf: synthslant-gauge.tex synthslant.sty
	perf stat --repeat=10 -- $(LATEX) $(LATEX_FLAGS) -interaction=batchmode -draftmode $<


.PHONY: tool-check
tool-check:
	@printf '***  LATEX_PROPER = "%s"\n' '$(LATEX_PROPER)'
	$(LATEX_PROPER) --version
	@printf '\n\n***  BibTeX\n'
	bibtex --version
	@printf '\n\n***  MAKEINDEX = "%s"\n' '$(MAKEINDEX)'
	$(MAKEINDEX)  < /dev/null
	@printf '\n\n***  METAPOST = "%s"\n' '$(METAPOST)'
	$(METAPOST) --version
	@printf '\n***  BASE64 = "%s"\n' '$(BASE64)'
	$(BASE64) --version
	@printf '\n\ntool check passed.\n'


.PHONY: update-docs
update-docs: pdf
	cp -f synthslant.pdf synthslant-gauge.pdf docs


define HELP_SCREEN
Selected Phony Targets
----------------------
all:    Make everything there is to make.  This is the .DEFAULT_GOAL.

clean:  Remove some products.

dist:   Create a tar file of the project source files and the PDF
        documentation files.  The archive is in the form and has a
        name that CTAN prefers.

distcheck: Create a tar file of the project source files, unpack it in
        a different location and build all targets.

doc:    Build "synthslant.pdf" the Syntslant documentation.

gauge:  Build "synthslant-gauge.pdf" the Syntslant gauge and example
        file.

maintainer-clean: Remove every product file that can be rebuilt even
        if uncommon tools are necessary.

mostlyclean: Remove some more products than clean:.

pdf:    Build doc: and gauge:.

sty:    Only extract "synthslant.sty" from "synthslant.dtx".  This
        operation requires LaTeX (-> $(LATEX)) and nothing else.

test:   Run some tests.  Currently only compiles a minimal document
        to check whether "synthslant.sty" contains all the necessary
        \RequirePackage directives.

tool-check: Check whether some of the required tools to build the
        project are available.

update-docs: Copy the documentation files into the "docs"
        sub-directory.


Selected Implicit Rules
-----------------------
%: %.html
        Convert HTML to plain text.  Requires w3m(1).

%.dvi %.pdf: %.dtx
        Run LaTeX or pdfLaTeX (-> $(LATEX)) on dtx source until a
        fix-point is reached.

%.dvi %.pdf: %.tex
        Run LaTeX or pdfLaTeX (-> $(LATEX)) on tex file until a
        fix-point is reached.

%.html: %.md
        Convert markdown to HTML.  Requires markdown(1).

%.mx.pdf: %.dvi
        Convert dvi to pdf via dvipdfmx (-> $(DVIPDFMX)).

%.ps: %.dvi
        Convert dvi to ps via dvips (-> $(DVIPS)).


Some Explicit Rules
-------------------
README.html:
        Convert "README.md" to html.

README: Convert "README.html" to plain text.

endef

.PHONY: help
help:
	$(info $(HELP_SCREEN))



.PRECIOUS: %.mps



define MAKE_INDEX_AND_GLOSSARY
sed -e '/@/d'  < $*.idx  > ,$*.idx;  mv ,$*.idx $*.idx;  \
$(MAKEINDEX) $(MAKEINDEX_FLAGS) -s $*.ist -t $*.ilg -o $*.ind $*.idx;  \
$(MAKEINDEX) $(MAKEINDEX_FLAGS) -s $*.gst -t $*.glg -o $*.gls $*.glo
endef

define GREP_LATEX_WARNINGS
test -e $*.log  &&  grep -E $(LATEX_WARNING) $*.log  |  uniq
endef

%.dvi %.pdf: %.dtx
	$(RM) ./$*.aux ./$*.ind ./$*.idx ./$*.gls ./$*.glo ./$*.lof ./$*.lot ./$*.toc
	$(LATEX) $(LATEX_FLAGS) -draftmode $<
	$(MAKE_INDEX_AND_GLOSSARY)
	$(LATEX) $(LATEX_FLAGS) $<
	$(MAKE_INDEX_AND_GLOSSARY)
	while test -e $*.log  &&  grep -q $(LATEX_RERUN_TRIGGER) $*.log;  \
        do  \
	    $(LATEX) $(LATEX_FLAGS) $<;  \
	    $(MAKE_INDEX_AND_GLOSSARY);  \
	done
	$(GREP_LATEX_WARNINGS)


%.dvi: LATEX=latex


%.dvi %.pdf: %.tex
	$(RM) ./$*.aux ./$*.ind ./$*.idx ./$*.lof ./$*.lot ./$*.toc
	$(LATEX) $(LATEX_FLAGS) -draftmode $<
	$(LATEX) $(LATEX_FLAGS) $<
	while test -e $*.log  &&  grep -q $(LATEX_RERUN_TRIGGER) $*.log;  \
        do  \
	    $(LATEX) $(LATEX_FLAGS) $<;  \
	done
	$(GREP_LATEX_WARNINGS)


%.mx.pdf: %.dvi
	$(DVIPDFMX) $(DVIPDFMX_FLAGS) -o $@ $<


%.ps: %.dvi
	$(DVIPS) $(DVIPS_FLAGS) -o $@ $<


%.mps: %.mp
	$(METAPOST) -s 'outputtemplate="%j.mps"' $(METAPOST_FLAGS) $<  ||  {  \
            printf '===  $*.log  ===\n';  \
            cat $*.log;  \
            printf '\n\n===  mpxerr.log  ===\n';  \
            cat mpxerr.log;  \
            false;  \
        }  1>&2


%.eps: %.png
	convert $< -compress lzw eps2:$@


%.html: %.md
	markdown $<  > $@

%: %.html
	w3m -cols 79 $<  > $@



synthslant.sty synthslant.ist  \
synthslant-gauge.tex synthslant-minimal-test.tex  \
compare-with-the-gimp.png.base64 shear-transform.mp title.mp:  \
  synthslant.ins synthslant.dtx
	$(LATEX) $(LATEX_FLAGS) $<


synthslant.pdf:  \
    synthslant.dtx  \
    compare-with-the-gimp.png  \
    shear-transform.mps  \
    title.mps  \
    | synthslant.sty

synthslant.dvi:  \
    synthslant.dtx  \
    compare-with-the-gimp.eps  \
    shear-transform.mps  \
    title.mps


compare-with-the-gimp.png: compare-with-the-gimp.png.base64
	$(BASE64) $(BASE64_FLAGS) --decode $<  > $@


shear-transform.mps: shear-transform.mp


title.mps: title.mp


##  compare-with-the-gimp.png: compare-with-the-gimp.orig.png
##       convert $< -depth 8 -resize 50% -set colorspace Gray -separate -average $@
##
##  compare-with-the-gimp.png.base64: compare-with-the-gimp.png
##       $(BASE64) $(BASE64_FLAGS) $<  > $@
