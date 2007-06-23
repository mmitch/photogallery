#!/bin/bash
# $Id: photogallery.sh,v 1.9 2007-06-23 21:48:04 mitch Exp $
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
# The gallery title is optional.
# Already existing thumbnails will not be overwritten.  If you change
# the thumbnail sizes ($MEDIUM and $SMALL) you need to remove the
# tumbnail subfolder before you can run photogallery.sh again.
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

html_head() {
    echo '<html><head>'
    echo "<title>$TITLE</title>"
    echo "<meta http-equiv=\"content-type\" content=\"text/html; charset=${CHARSET}\">"
    echo '</head><body>'
}

html_foot() {
    echo '<hl><p><small><i>generated on ' "$(LANG=${DATELANG} date)" 'by $Id: photogallery.sh,v 1.9 2007-06-23 21:48:04 mitch Exp $</i></small></p></body></html>'
}

#### main script

mkdir -p $SUBDIR
exec > $INDEX

html_head

if [ -r "../$INDEX" ] ; then
    echo -n "<p><a href=\"../$INDEX\">up</a>"
else
    echo -n '<p><a href="..">up</a>'
fi
for DIR in *; do

    [ -d "$DIR" ] || continue
    [ -r "$DIR" ] || continue
    [ "${DIR:0:1}" = '.' ] && continue

    echo '<br>'
    if [ -r "$DIR/$INDEX" ] ; then
	echo -n "<a href=\"$DIR/$INDEX\">$DIR</a>"
    else
	echo -n "<a href=\"$DIR\">$DIR</a>"
    fi

    echo -n : 1>&2

done
echo '</p><hl>'

for FILE in *; do

    [ -f "$FILE" ] || continue
    [ -r "$FILE" ] || continue

    EXT="${FILE/*.}"
    M_INDEX="${FILE%.*}_m.html"
    M_FILE="${FILE%.*}_m.jpg"
    S_FILE="${FILE%.*}_s.jpg"

    if [ ! -s "$SUBDIR/$M_FILE" ] ; then
	case "$EXT" in
	    
	    gif|jpg|JPG|png|tif|tiff)
		convert -scale $MEDIUM "$FILE" "$SUBDIR/$M_FILE"
		;;
	    
	    pef|PEF)
		dcraw -c -w -o1 -h "$FILE" | convert -scale $MEDIUM ppm:- "$SUBDIR/$M_FILE"
		;;
	    
	    *)
		continue
		;;
	    
	esac
    fi

    [ -s "$SUBDIR/$S_FILE" ] || convert -scale $SMALL "$SUBDIR/$M_FILE" "$SUBDIR/$S_FILE"

    chmod --reference="$FILE" "$SUBDIR/$M_FILE"
    chmod --reference="$FILE" "$SUBDIR/$S_FILE"

    echo "<a href=\"$SUBDIR/$M_INDEX\" alt=\"$FILE\"><img src=\"$SUBDIR/$S_FILE\" /></a>"

    (
	html_head
	echo '<p><a href="../$INDEX">up</a></p><hl>'
	echo "<a href=\"../$FILE\" alt=\"$FILE\"><img src=\"$M_FILE\" /></a>"
	html_foot
	
    ) > "$SUBDIR/$M_INDEX"

    echo -n . 1>&2

done

html_foot

echo 1>&2
