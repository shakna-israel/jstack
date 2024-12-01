BOOK_FILES=`find . -type f -name '*.md' | grep -v index.md | sort -n`

default: all

.PHONY: books
books: book.epub book.pdf book.html stats

all: index.md
	$(MAKE) -j8 books

book.html: index.md
	pandoc index.md $(BOOK_FILES) -o book.html --embed-resources --standalone

.DELETE_ON_ERROR: book.epub
book.epub: index.md
	pandoc index.md $(BOOK_FILES) -o book.epub --standalone
	epubcheck book.epub

book.pdf: index.md
	pandoc index.md $(BOOK_FILES) -fmarkdown -o book.pdf --listings -H header.latex

.PHONY: stats
stats: book.pdf book.epub book.html
	@pdfinfo book.pdf | grep Pages | awk '{print "Pages: " $$2}'
	@cat *.md | wc -w
	@ls -lah book.epub | awk '{print $$5 " " $$NF}'
	@ls -lah book.pdf | awk '{print $$5 " " $$NF}'
	@ls -lah book.html | awk '{print $$5 " " $$NF}'

.PHONY: clean
clean:
	-rm book.epub
	-rm book.pdf
	-rm book.html
