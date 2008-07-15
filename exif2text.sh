#!/bin/bash
#
# 2008 (c) by Christian Garbs <mitch@cgarbs.de>
#
# add exif tags for photogallery.sh gallery
# licensed under GNU GPL v2
#

for FILE in "${@}"; do
    (
	F=$(exiftool -q -s -s -s -FocalLength   "${FILE}")
	A=$(exiftool -q -s -s -s -ApertureValue "${FILE}")
	E=$(exiftool -q -s -s -s -ExposureTime  "${FILE}")
    
	SEP=''
	[ "$F" ] && echo -n "f=${F}" && SEP=', '
	[ "$E" ] && echo -n "${SEP}" && echo -n "${E}s" && SEP=', '
	[ "$A" ] && echo -n "${SEP}" && echo -n "1:${A}" && SEP=', '
	[ "$SEP" ] && echo
    ) >> "${FILE}.text"
done