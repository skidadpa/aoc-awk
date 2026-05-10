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
num=${1#day}
pref=${1%[0-2][0-9]}
if [[ ("$pref" != "day") || ("$pref$num" != "$1") || ("$num" == "") ]]
then
    echo "ERROR: directory must be in form dayNN, where NN is a number from 00-29" >&2
    exit 1
fi
cp -r ../template/day00 $1
make -C $1 input.txt
