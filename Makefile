# This Makefile is part of photogallery.
#
# Copyright (C) 2008,2009  Christian Garbs <mitch@cgarbs.de>
# licensed under GNU GPL v2 or later
#
#    photogallery is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    photogallery program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

DIR=photogallery-$(VERSION)
TGZ=photogallery-$(VERSION).tar.gz

DOCS=HISTORY README COPYING photogallery-conf.pl.sample
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
