#!/bin/bash
cd $(dirname $0)
PASS_COUNT=0
FAIL_COUNT=0
export PREVENT_LONG_RUN=1
for d in day*
do
    echo + $d
    make -C $d && ((++PASS_COUNT)) || ((++FAIL_COUNT))
done
echo
echo PASS_COUNT: $PASS_COUNT
echo FAIL_COUNT: $FAIL_COUNT
exit $FAIL_COUNT
