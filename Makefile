DIR=photogallery-$(VERSION)
TGZ=photogallery-$(VERSION).tar.gz

DOCS=HISTORY README photogallery-conf.pl.sample
PERL_REPL=photogallery_diff2rss photogallery_diff2html photogallery_diff
BASH_REPL=editcomments exif2text
BASH_SRC=photogallery

VERSION=$(shell grep ^VERSION= $(BASH_SRC) | sed s/^VERSION=//)

dist:	clean
	mkdir -p $(DIR)
	install -m 0755 $(BASH_SRC) $(DIR)
	for I in $(BASH_REPL); do \
		sed -e "s/^VERSION=.*/VERSION=$(VERSION)/" < $$I > $(DIR)/$$I; \
		chmod 755 $(DIR)/$$I; \
	done
	for I in $(PERL_REPL); do \
		sed -e "s/^my \$$VERSION=.*/my \$$VERSION='$(VERSION)';/" < $$I > $(DIR)/$$I; \
		chmod 755 $(DIR)/$$I; \
	done
	for I in $(DOCS); do \
		install -m 0644 $$I $(DIR); \
	done
	tar -czvf $(TGZ) $(DIR)

clean:
	rm -rf $(DIR) $(TGZ)
	rm -rf *~
