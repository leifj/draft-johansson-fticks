DOC=draft-johansson-fticks
VER=01

## Change nothing below this line unless you know what you're doing

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

REPO=$(shell git config remote.origin.url | sed 's!^git@github.com:!https://github.com/!')

deploy: $(HTML)
	mv $(HTML) /tmp
ifndef TRAVIS_PULL_REQUEST
	git remote | grep -q pages || git remote add -t gh-pages pages $(REPO)
ifdef GIT_NAME
	git config -l | grep -q user.name || git config user.name $(GIT_NAME)
endif
ifdef GIT_EMAIL
	git config -l | grep -q user.email || git config user.email $(GIT_EMAIL)
endif
ifdef GIT_TOKEN
	echo "https://$(GH_TOKEN):@github.com" >> .git/credentials && git config credential.helper "store --file=.git/credentials"
endif
	git branch | grep -v '/' | grep -q gh-pages || git branch gh-pages pages/gh-pages
	git checkout gh-pages && git merge -m "merge" master
	mv /tmp/$(HTML) . && git add $(HTML)
	rm -f index.html && cp $(HTML) index.html && git add index.html
	git commit -m "$(HTML)" $(HTML) index.html || /bin/true
	git checkout master
	git push --all
ifdef GIT_TOKEN
	rm -f .git/credentials
endif
endif # travis pull request
