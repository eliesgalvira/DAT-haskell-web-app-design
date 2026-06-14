
.PHONY= help build serve browse dbg-build dbg-repl clean

js_cabal=../js-cabal
app=forums-frontend
browser=google-chrome
#browser=chromium

help:
	@echo "Targets: build serve browse dbg-build dbg-repl clean"

build:
	$(js_cabal) build $(app)
	rm -rf public
	cp -r static public
	cd public; ln -s index.html topic.html
	$(eval app_bin=$(shell $(js_cabal) list-bin $(app) | tail -n 1))
	cp -v $(app_bin).jsexe/all.js public/

serve:
	cabal run http-serve public

browse:
	$(browser) --disable-web-security --disable-site-isolation-trials --user-data-dir=browse-user-data \
	  http://localhost:8008/index.html

dbg-build:
	cabal build $(app)

dbg-repl:
	cabal repl $(app)

clean:
	rm -rf public browse-user-data

