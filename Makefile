VERSION=$(shell grep ^VERSION= photogallery | sed s/^VERSION=//)
DIR=photogallery-$(VERSION)/
TGZ=photogallery-$(VERSION).tar.gz

DOCS=HISTORY README photogallery-conf.pl.sample
PERL=photogallery_diff2rss photogallery_diff2html photogallery_diff
BASH=photogallery editcomments.sh exif2text

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
