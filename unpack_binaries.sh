#!/bin/sh -x

for u in *.Z.uu ; do
	z=`basename $u .uu`
	f=`basename $z .Z`
	uudecode $u
	uncompress $z
	rm -f $u $z
	done

for t in *.tar ; do
	f=`basename $t .tar`
	tar xf $t
	rm -f $t
	done
