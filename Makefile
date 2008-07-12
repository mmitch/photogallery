VERSION=$(shell grep ^VERSION= photogallery.sh | sed s/^VERSION=//)
DIR=photogallery-$(VERSION)/
TGZ=photogallery-$(VERSION).tar.gz

DOCS=HISTORY README photogallery-conf.pl.sample
PERL=photogallery_diff2rss.pl photogallery_diff2html.pl photogallery_diff.pl
BASH=photogallery.sh editcomments.sh

dist:	clean
	mkdir -p $(DIR)
	for I in $(BASH) $(PERL); do \
		install -m 0755 $$I $(DIR); \
	done
	for I in $(DOCS); do \
		install -m 0644 $$I $(DIR); \
	done
	tar -czvf $(TGZ) $(DIR)

clean:
	rm -rf $(DIR) $(TGZ)
	rm -rf *~
