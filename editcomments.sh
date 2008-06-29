#!/bin/sh
#
# edit comments for photogallery.sh gallery

TEMP=$(mktemp)

for FILE in "${@}"; do

    echo "====$FILE"
    [ -e "$FILE.text" ] && cat "$FILE"

done > $TEMP

$EDITOR $TEMP

rm $TEMP