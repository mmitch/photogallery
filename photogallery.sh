#!/bin/bash
# $Id: photogallery.sh,v 1.3 2007-06-23 21:11:13 mitch Exp $
#
# simple static photogallery script
# 2007 (c) by Christian Garbs <mitch@cgarbs.de>
# licensed under GNU GPL

#### commandline parameters

TITLE=${1:-photogallery}

#### configuration

MEDIUM=640x640
SMALL=20%
SUBDIR=.webthumbs
INDEX=index.html

#### function declarations

html_head() {
    echo "<html><head><title>$TITLE</title></head><body>"
    echo '<p><a href="..">up</a></p><hl>'
}

html_foot() {
    echo '<hl><p><small><i>generated on ' "$(date)" 'by $Id: photogallery.sh,v 1.3 2007-06-23 21:11:13 mitch Exp $</i></small></p></body></html>'
}

#### main script

mkdir -p $SUBDIR
exec > $INDEX

html_head

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

    echo "<a href=\"$SUBDIR/$M_INDEX\" alt=\"$FILE\"><img src=\"$SUBDIR/$S_FILE\" /></a>"

    (
	html_head
	echo "<a href=\"../$FILE\" alt=\"$FILE\"><img src=\"$M_FILE\" /></a>"
	html_foot
	
    ) > "$SUBDIR/$M_INDEX"

    echo -n . 1>&2

done

html_foot

echo 1>&2
