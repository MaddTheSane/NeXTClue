#!/bin/sh -u

AWK=/bin/awk
FIND=/usr/bin/find
RLOG=/usr/bin/rlog
RCS=/usr/bin/rcs

VERSION=$1

RCSDIRS=`$FIND . -name RCS -print`

for d in $RCSDIRS ; do
    for f in $d/* ; do
	TIP=`$RLOG -h $f | $AWK '/head:/ {print $2}'`
	echo "$RCS -q -N$1:$TIP $f"
	$RCS -q -N$1:$TIP $f
	done
    done
