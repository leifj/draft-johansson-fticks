DOC=draft-johansson-fticks

## Change nothing below this line unless you know what you're doing

VER=$(shell python -c 'from lxml import etree; print etree.parse("$(DOC).xml").find("[@docName]").get("docName").split("-")[-1]')
TEXT=$(DOC)-$(VER).txt
HTML=$(DOC)-$(VER).html

all: $(TEXT) $(HTML) 

$(TEXT): $(DOC).xml
	xml2rfc $< -o $@

$(HTML): $(DOC).xml
	xml2rfc $< --html -o $@

clean:
	rm -f *.html *.txt *~

.git/credentials:
	echo "https://$(GH_TOKEN):@github.com" >> .git/credentials

REPO=$(shell git config remote.origin.url | sed 's!^git://github.com!https://github.com!')

travis: $(HTML)
ifeq ("$(TRAVIS_PULL_REQUEST)", "false")
	mv $(HTML) /tmp
	git remote set-url --push origin $(REPO)
	git remote set-branches --add origin gh-pages
	git fetch -q
ifdef GIT_NAME
	git config -l | grep -q user.name || git config user.name $(GIT_NAME)
endif
ifdef GIT_EMAIL
	git config -l | grep -q user.email || git config user.email $(GIT_EMAIL)
endif
ifdef GH_TOKEN
	echo "https://$(GH_TOKEN):@github.com" >> .git/credentials && git config credential.helper "store --file=.git/credentials"
endif
	git branch gh-pages origin/gh-pages
	git checkout gh-pages && git merge -m "merge master" master
	mv /tmp/$(HTML) . && git add $(HTML)
	rm -f index.html && cp $(HTML) index.html && git add index.html
	git commit -m "$(HTML)" $(HTML) index.html || /bin/true
	git push origin gh-pages
ifdef GH_TOKEN
	rm -f .git/credentials
endif
endif
