all: build/template/Overview.html

build/template/Overview.html: template/template.html
	cp template/template.html $@
#	cd template && tar cf - graphics | (cd ../build/template; tar xf -)

template/template.html: template/template.xml
	mkdir -p build/template
	$(MAKE) -C template

clean:
	rm -rf build
	$(MAKE) -C template clean
