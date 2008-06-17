#!/bin/bash
#
# simple static photogallery script
# 2007-2008 (c) by Christian Garbs <mitch@cgarbs.de>
# licensed under GNU GPL

#
# usage:
#    photogallery.sh [gallerytitle]
#
# Run this script inside a directory with pictures.
# It will generate a subfolder (set via $SUBDIR) with some thumbnails
# and an HTML index file (set via $INDEX).
# The gallery title is optional and defaults to the current directory
# name.
# To describe a gallery, put a file named README into the directory.
# It will be included in the generated HTML index file.
# To describe an image some.jpeg, put a file named some.jpeg.text into
# the same directory.
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
#    sed
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

GALLERYCSS=
THUMBCSS=

#### function declarations

status() {
    echo "$@" 1>&2
}

html_head() {
    CSS="$1"
    echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml1.dtd">'
    echo '<html><head>'
    echo "<title>$TITLE</title>"
    if [ "$CSS" ] ; then
	echo '<style type="text/css"><!--'
	echo $CSS
	echo '--></style>'
    fi
    echo "<meta http-equiv=\"content-type\" content=\"text/html; charset=${CHARSET}\" />"
    echo '</head><body>'
}

html_foot() {
    echo '<p><small><small><i>generated on ' "$(LANG=${DATELANG} date)" 'by <a href="http://www.cgarbs.de/cgi-bin/gitweb.cgi/photogallery.git">photogallery.sh</a></i></small></small></p></body></html>'
}

#### main script

exec > $INDEX

html_head "$GALLERYCSS"

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

declare -a FILES
for FILE in *; do
    [ -f "$FILE" ] || continue
    [ -r "$FILE" ] || continue
    EXT="${FILE/*.}"

    case "$EXT" in 
	gif|jpeg|jpg|JPG|png|tif|tiff)
	    ;;
	pef|PEF)
	    ;;
	*)
	    continue
	    ;;
    esac

    FILES+=("$FILE")
done

status -n "${#FILES[*]}>"

for (( IDX=0; $IDX < ${#FILES[*]}; IDX+=1 )) ; do

    FILE="${FILES[${IDX}]}"

    EXT="${FILE/*.}"
    M_INDEX="${FILE}_m.html"
    M_FILE="${FILE}_m.jpg"
    S_FILE="${FILE}_s.jpg"

    if [ ! -s "$SUBDIR/$M_FILE" ] ; then
	case "$EXT" in
	    
	    gif|jpeg|jpg|JPG|png|tif|tiff)
		convert -resize $MEDIUM -sharpen 1x0.5 "$FILE" "$SUBDIR/$M_FILE"
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
		dcraw -c -w -o1 -h -t $FLIP "$FILE" | convert -resize $MEDIUM -sharpen 1x0.5 ppm:- "$SUBDIR/$M_FILE"
		;;
	    
	    *)
		continue
		;;
	    
	esac
    fi

    [ -s "$SUBDIR/$S_FILE" ] || convert -resize $SMALL "$SUBDIR/$M_FILE" -sharpen 1x0.5 "$SUBDIR/$S_FILE"

    chmod --reference="$FILE" "$SUBDIR/$M_FILE"
    chmod --reference="$FILE" "$SUBDIR/$S_FILE"

    if [ -s "${FILE}.text" ] ; then
	FILETEXT="$(<"${FILE}.text")"
	ALTTEXT="$FILETEXT"
    else
	FILETEXT=
	ALTTEXT="${FILE}"
    fi
    ALTTEXT=$( echo "$ALTTEXT" | sed -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' )

    if [ "$FILETEXT" ] ; then
	echo "<a href=\"$SUBDIR/$M_INDEX\"><img border=3 alt=\"\" title=\"$ALTTEXT\" src=\"$SUBDIR/$S_FILE\" /></a>"
    else
	echo "<a href=\"$SUBDIR/$M_INDEX\"><img border=1 alt=\"\" title=\"$ALTTEXT\" src=\"$SUBDIR/$S_FILE\" /></a>"
    fi

    (
	html_head "$THUMBCSS"
	echo -n "<p>"
	PREV=$(( $IDX - 1 ))
	NEXT=$(( $IDX + 1 ))
	if [ $IDX -gt 0 ] ; then
	    echo -n "<p><a href=\"${FILES[${PREV}]}_m.html\">&lt;&lt;</a>"
	else
	    echo -n "<p>&lt;&lt;"
	fi
	echo " &nbsp; <a href=\"../$INDEX\">back</a> &nbsp; "
	if [ $NEXT -lt ${#FILES[*]} ] ; then
	    echo "<a href=\"${FILES[${NEXT}]}_m.html\">&gt;&gt;</a></p>"
	else
	    echo "&gt;&gt;</p>"
	fi
	echo "</p>"
	echo "<p><a href=\"../$FILE\"><img alt=\"$FILE\" src=\"$M_FILE\" /></a></p>"

	[ "$FILETEXT" ] && echo "<p>${FILETEXT}</p>"

	html_foot
	
    ) > "$SUBDIR/$M_INDEX"

    if [ $(( $IDX % 10 )) == 9 ]; then
	status -n $(( $IDX + 1 ))
    else
	status -n .
    fi

done

echo '</p>'
echo '<!--'
echo PICTURES=${#FILES[*]}
echo SUBDIRS=$SUBDIRS
echo DATE=`date +%Y%m%d%H%M%S`
echo '-->'

html_foot

if [ ${#FILES[*]} == 0 ] ; then
    rmdir "$SUBDIR"
fi

status
