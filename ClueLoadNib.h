#ifndef __ClueLoadNib_h
#define __ClueLoadNib_h
//-----------------------------------------------------------------------------
// ClueLoadNib.h
//
//	Simplified routine to load nib files for the Clue program.
//
//	ClueLoadNib( id obj )
//		Uses [[obj class] name] ".nib" for the name of the nib file.
//		Uses [NXBundle mainBundle] to locate the file.
//		Uses [Application loadNibFile:... owner:<obj> withNames:NO]
//			to load the nib file.
//		Terminates with exit(3) on error.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <objc/objc.h>		// for 'id'
}

void ClueLoadNib( id obj );

#endif // __ClueLoadNib_h
