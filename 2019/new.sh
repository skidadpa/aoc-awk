#!/bin/bash
cd $(dirname $0)
if (( $# != 1 ))
then
    echo "Create a new day directory and update input.txt" >&2
    echo "Usage:" >&2
    echo " $0 dayNN" >&2
    exit 1
fi
if [[ -e $1 ]]
then
    echo "ERROR: $1 already exists" >&2
    exit 2
fi
cp -r ../template/day00 $1
make -C $1 input.txt
