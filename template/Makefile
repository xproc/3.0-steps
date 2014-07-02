SAXON=saxon
TIDY=/usr/bin/tidy
CALABASH=calabash
SPEC=../../specification

TARGETS=template.html

all: $(TARGETS)

template.html: ,template.xml \
               $(SPEC)/style/docbook.xsl $(SPEC)/style/dbspec.xsl \
               $(SPEC)/style/xprocns.xsl $(SPEC)/style/rngsyntax.xsl
	$(SAXON) $< $(SPEC)/style/dbspec.xsl $@
	$(TIDY) --doctype loose --output-xhtml true -q -utf8 -mn $@

,template.xml: template.xml examples/doctemp-1.xml examples/doctemp-2.xml
	$(CALABASH) -isource=$< -oresult=$@ \
                    $(SPEC)/style/validate.xpl schema=$(SPEC)/schema/dbspec.rng

clean:
	rm -f ,template.xml $(TARGETS)
