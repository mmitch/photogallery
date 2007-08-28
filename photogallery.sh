#!/bin/bash
# $Id: photogallery.sh,v 1.24 2007-08-28 21:10:41 mitch Exp $
#
# simple static photogallery script
# 2007 (c) by Christian Garbs <mitch@cgarbs.de>
# licensed under GNU GPL

#
# usage:
#    photogallery.sh [gallerytitle]
#
# Run this script inside a directory with pictures.
# It will generate a subfolder (set via $SUBDIR) with some thumbnails
# and an HTML index file (set via $INDEX).
# The gallery title is optional and defaults to the current directory.
# A file named README will included in the generated HTML index.
# 
# Already existing thumbnails will not be overwritten.  If you change
# the thumbnail sizes ($MEDIUM and $SMALL) you need to remove the
# thumbnail subfolder before you can run photogallery.sh again.
#
# To generate lots of galleries in subdirectories use this (only
# works if there are no line breaks in your directory names):
# 
#   find . -depth \! -name .\* -type d | \
#   while read DIR; do ( echo "$DIR"; cd "$DIR"; photogallery.sh ) ; done
#
# If you want to browse your galleries directly from your filesystem
# without a webserver, you have to run this twice so that all links
# are generated properly!
#
#
# External commands needed:
#    convert from Imagemagick
#    dcraw (only if you want to convert RAW files)
#

#### commandline parameters

TITLE=${1:-${PWD##*/}}

#### configuration

CHARSET=UTF-8
DATELANG=C
MEDIUM=640x640
SMALL=20%
SUBDIR=.webthumbs
INDEX=index.html

#### function declarations

status() {
    echo "$@" 1>&2
}

html_head() {
    echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml1.dtd">'
    echo '<html><head>'
    echo "<title>$TITLE</title>"
    echo "<meta http-equiv=\"content-type\" content=\"text/html; charset=${CHARSET}\" />"
    echo '</head><body>'
}

html_foot() {
    echo '<p><small><small><i>generated on ' "$(LANG=${DATELANG} date)" 'by $Id: photogallery.sh,v 1.24 2007-08-28 21:10:41 mitch Exp $</i></small></small></p></body></html>'
}

#### main script

exec > $INDEX

html_head

if [ -r "../$INDEX" ] ; then
    echo -n "<p><a href=\"../$INDEX\">[ up ]</a>"
else
    echo -n '<p><a href="..">[ up ]</a>'
fi

SUBDIRS=0
for DIR in *; do

    [ -d "$DIR" ] || continue
    [ -r "$DIR" ] || continue
    [ "${DIR:0:1}" = '.' ] && continue

    echo '<br />'
    if [ -r "$DIR/$INDEX" ] ; then
	echo -n "<a href=\"$DIR/$INDEX\">$DIR/</a>"
    else
	echo -n "<a href=\"$DIR\">$DIR/</a>"
    fi

    status -n :
    let SUBDIRS++

done
echo '</p>'

status -n "$SUBDIRS "

if [ -e README ] ; then
    echo '<p>'
    cat < README
    echo '</p>'
fi

mkdir -p "$SUBDIR" || exit 1

echo '<p>'
PICTURES=0
for FILE in *; do

    [ -f "$FILE" ] || continue
    [ -r "$FILE" ] || continue

    EXT="${FILE/*.}"
    M_INDEX="${FILE}_m.html"
    M_FILE="${FILE}_m.jpg"
    S_FILE="${FILE}_s.jpg"

    if [ ! -s "$SUBDIR/$M_FILE" ] ; then
	case "$EXT" in
	    
	    gif|jpeg|jpg|JPG|png|tif|tiff)
		convert -scale $MEDIUM "$FILE" "$SUBDIR/$M_FILE"
		;;
	    
	    pef|PEF)
		FLIP=0
		if [ -e "$FILE.rotation" ] ; then
		    case $(< "$FILE.rotation") in
			180)  FLIP=3 ;;
			90)  FLIP=6 ;;
			270)  FLIP=5 ;;
		    esac
		fi
		dcraw -c -w -o1 -h -t $FLIP "$FILE" | convert -scale $MEDIUM ppm:- "$SUBDIR/$M_FILE"
		;;
	    
	    *)
		continue
		;;
	    
	esac
    fi

    [ -s "$SUBDIR/$S_FILE" ] || convert -scale $SMALL "$SUBDIR/$M_FILE" "$SUBDIR/$S_FILE"

    chmod --reference="$FILE" "$SUBDIR/$M_FILE"
    chmod --reference="$FILE" "$SUBDIR/$S_FILE"

    echo "<a href=\"$SUBDIR/$M_INDEX\"><img alt=\"$FILE\" src=\"$SUBDIR/$S_FILE\" /></a>"

    (
	html_head
	echo "<p><a href=\"../$INDEX\">&lt;&lt; back</a></p>"
	echo "<p><a href=\"../$FILE\"><img alt=\"$FILE\" src=\"$M_FILE\" /></a></p>"
	html_foot
	
    ) > "$SUBDIR/$M_INDEX"

    status -n .
    let PICTURES++

done
echo '</p>'
echo '<!--'
echo PICTURES=$PICTURES
echo SUBDIRS=$SUBDIRS
echo DATE=`date +%Y%m%d%H%M%S`
echo '-->'

html_foot

status $PICTURES

[ $PICTURES -eq 0 ] && rmdir "$SUBDIR"