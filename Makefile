all: draft-johansson-fticks.txt draft-johansson-fticks.html

%.txt: %.xml
	xml2rfc $< $@

%.html: %.xml
	xml2rfc $< $@

clean:
	rm -f *.html *.txt *~
