#!/bin/sh

for t in *.tiff *.lproj/*.tiff ; do
    if [ "$t" != "*.tiff" -a "$t" != "*.lproj/*.tiff" ] ; then
	z=$t.Z
	u=$z.uu
	set -x
	compress $t
	uuencode $z $z > $u
	rm -f $t $z
	set -
	fi
    done

for n in *.rtfd *.nib *.lproj/*.rtfd *.lproj/*.nib ; do
    if [ "$n" != "*.rtfd" -a "$n" != "*.nib" -a \
	"$n" != "*.lproj/*.rtfd" -a "$n" != "*.lproj/*.nib" ] ; then
	t=$n.tar
	z=$t.Z
	u=$z.uu
	set -x
	tar cf $t $n
	compress $t
	uuencode $z $z > $u
	rm -rf $n $t $z
	set -
	fi
    done
