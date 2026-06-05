#!/bin/bash
#
# run-all-tests.sh - part of the test infrastructore of the photogallery proiect
#
# Copyright (C) 2026  Christian Garbs <mitch@cgarbs.de>
# licensed under GNU GPL v2 or later
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

set -e

echo "running all tests..."
echo

ran=0
success=0
for test in *.test; do

    echo ">>>> $test"
    echo

    if ./$test; then
	(( ++success ))
    fi
    (( ++ran ))

    echo
    echo "==== $test"
    echo
    
done

failed=$(( ran - success ))

echo "TESTS FINISHED:"
printf '%3d tests total\n' "$ran"
printf '%3d successful tests\n' "$success"
printf '%3d failed tests\n' "$failed"
echo

if [[ $failed -eq 0 ]]; then
    echo "ALL TESTS OK."
else
    echo "$failed TESTS FAILED."
    exit 1
fi
