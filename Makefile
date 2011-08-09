BUILDDIR = ./build
FILES_MAIN = $(wildcard *.markdown)
FILES_UPRAJNENIA = $(wildcard ./uprajnenia/*.markdown) 
FILES_RECEPTI = $(wildcard ./recepti/*.markdown)
FILES_ALL = $(FILES_MAIN) $(FILES_UPRAJNENIA) $(FILES_RECEPTI)
.PHONY: clean spell

all:	html epub

html: *.markdown style.css Makefile
	pandoc -s --css=style.css --toc -o $(BUILDDIR)/index.html $(FILES_ALL)
	cp style.css $(BUILDDIR)

epub: *.markdown style.css Makefile
	pandoc -t epub --epub-metadata=metadata.xml -s --epub-stylesheet=style.css --toc -o $(BUILDDIR)/book.epub $(FILES_ALL)

clean:
	rm -f $(BUILDDIR)/*.html
	rm -f $(BUILDDIR)/*.css
	rm -f $(BUILDDIR)/*.epub
	rm -f *.bak

spell:
	for i in $(FILES_ALL); do aspell --lang=bg_BG check $$i; done
