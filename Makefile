#
# Slug: filename prefix that will be used for the generated
# files. e.g. example.epub and example.pdf, plus intermediate
# files like example.tex
#
SLUG=example

#
# The main text of the book. This sequence determines the
# chapter order.
#
CONTENTS = \
	text/beginning.md\
	text/middle.md\
	text/end.md\
	\
#
# The stuff in the back, not part of the story.
#
BACKMATTER = \
	text/ack.md \
	text/about.md\
	\

TEXT = $(CONTENTS) $(BACKMATTER)

#
# The cover image
# 
COVER = images/cover.jpg

#
# Epub stylesheets, one for indented style formatting, another for block style.
#
STYLESHEET = css/stylesheet-epub-indent.css
#STYLESHEET = css/stylesheet-epub-block.css


#
# generic args for pandoc, 
# If you want subchapters in the TOC, set --toc-depth=2.
PANDOC_ARGS = \
	--toc \
	--toc-depth=1 \

#LATEX = pdflatex -interaction=nonstopmode
LATEX = pdflatex


##############################
# TARGETS
#
# The main targets are epub and pdf.
# The view targets open the document
#
all: epub pdf ms
epub: out/$(SLUG).epub
pdf: out/$(SLUG).pdf
ms: out/$(SLUG)-ms.pdf
view: view-epub
unzip: out/$(SLUG).unzip

# These targets are macos specific. 
# view-epub assumes that Calibre is installed for viewing
# epubs.
view-epub: out/$(SLUG).epub
	open -a ebook-viewer $<
view-pdf: out/$(SLUG).pdf
	open $<
view-ms: out/$(SLUG)-ms.pdf
	open $<

################

### EPUB
out/$(SLUG).epub: metadata.yaml $(CONTENTS) $(BACKMATTER) $(STYLESHEET) $(COVER) | out
	pandoc 	$(PANDOC_ARGS) \
		-o out/$(SLUG).epub \
		--css=$(STYLESHEET) \
		--number-sections\
		metadata.yaml \
		$(CONTENTS) $(BACKMATTER)

# if you want to see what's being built inside the epub
# you can unzip it and look at the files.
out/$(SLUG).unzip: out/$(SLUG).epub | out
	rm -rf out/$(SLUG).unzip
	unzip out/$(SLUG).epub -d out/$(SLUG).unzip

### PDF
out/%.pdf: %.tex | out
	$(LATEX) $<
	$(LATEX) $<
	mv `basename $@` $@


### LaTeX - needed for pdf
$(SLUG).tex: templates/book.tex metadata.yaml $(CONTENTS) tmp/backmatter.tex
	pandoc $(PANDOC_ARGS) \
		--template=templates/book.tex \
		-o $@ metadata.yaml \
		--top-level-division=chapter \
		--metadata=ts:"`date`" \
		$(CONTENTS)

### Manuscript-format Latex
$(SLUG)-ms.tex: templates/sffms.tex metadata.yaml $(CONTENTS)
	pandoc $(PANDOC_ARGS) \
		--template=templates/sffms.tex \
		-o $@ metadata.yaml \
		--top-level-division=chapter \
		--metadata=ts:"`date`" \
		$(CONTENTS)

tmp/backmatter.tex: $(BACKMATTER) | tmp
	pandoc $(PANDOC_ARGS)\
		--top-level-division=chapter \
		-o $@ $^

# GENERAL 
tkcheck:
	! grep TK $(TEXT) 

out:
	mkdir out

tmp:
	mkdir tmp

clean:
	rm -vrf out tmp
	rm -vf *.tex *.aux *.log *.toc *.out