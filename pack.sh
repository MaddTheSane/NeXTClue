#!/bin/sh
#-----------------------------------------------------------------------------
# pack.sh
#
#	Create a source code package.
#
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# $Id$
# $Log$
#-----------------------------------------------------------------------------

ROOT=Clue
PACKAGE=$ROOT

AWK=/bin/awk
CAT=/bin/cat
EXPR=/bin/expr
RM=/bin/rm
TEST=/bin/test
FIND=/usr/bin/find
GNUTAR=/usr/bin/gnutar
RLOG=/usr/bin/rlog
RCS=/usr/bin/rcs
CI=/usr/bin/ci
CO=/usr/bin/co

cd ..
RCSDIRS=`$FIND $ROOT -name RCS -print`
HELPDIRS=`$FIND $ROOT -name Help -print`
cd $ROOT

TARDIRS=$RCSDIRS $HELPDIRS


echo "What's locked..."
for d in $RCSDIRS ; do
	$RLOG -L $d/* | \
	$AWK '/^RCS file:/ { printf "%-70s", $3 } \
		/locked by:/ { printf " %s\n", $5 }'
	done

echo ""
echo -n "Proceed? (y/n) [n] : "
read answer
if $TEST "$answer" != "y" ; then
    echo "aborted."
    exit 1
    fi

PKG=`$CAT PACKAGE_NUMBER`
PKG=`$EXPR $PKG + 1`

echo -n "Enter package number to use [$PKG] :"
read answer
if $TEST -n "$answer" ; then
    PKG=$answer
    fi

./freeze.sh "v$PKG"

PACKAGE_FILE=$PACKAGE.v${PKG}.tar.gz
echo "PACKAGE_FILE is [$PACKAGE_FILE]"

if $TEST -f ../$PACKAGE_FILE ; then
    echo -n "This package already exists.  Delete it and proceed? (y/n) [n] : "
    read answer
    if $TEST "$answer" != "y" ; then
	echo "aborted."
	exit 1
	fi
    $RM -f ../$PACKAGE_FILE
    if $TEST -f ../$PACKAGE_FILE ; then
	echo "Could not delete the existing package... pack failed."
	exit 1
	fi
    fi

set -x
$RM -f PACKAGE_NUMBER
echo $PKG > PACKAGE_NUMBER

$RM -f RCS/PACKAGE_NUMBER,v
$CI PACKAGE_NUMBER << EOS_CI
Package Number
EOS_CI
$RCS -L RCS/PACKAGE_NUMBER,v
$CO RCS/PACKAGE_NUMBER,v


cd ..
$GNUTAR czvf $PACKAGE_FILE $TARDIRS
