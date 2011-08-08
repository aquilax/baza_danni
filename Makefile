BUILDDIR = ./build

.PHONY: clean spell

all:	html epub

html: *.markdown style.css Makefile
	pandoc -s --css=style.css --toc -o $(BUILDDIR)/index.html *.markdown
	cp style.css $(BUILDDIR)

epub: *.markdown style.css Makefile
	pandoc -t epub --epub-metadata=metadata.xml -s --epub-stylesheet=style.css --toc -o $(BUILDDIR)/book.epub *.markdown

clean:
	rm -f $(BUILDDIR)/*.html
	rm -f $(BUILDDIR)/*.css
	rm -f $(BUILDDIR)/*.epub
	rm -f *.bak

spell:
	for i in *.markdown; do aspell --lang=bg_BG check $$i; done
