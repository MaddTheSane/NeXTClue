//-----------------------------------------------------------------------------
// ClueLoadNib.M
//
//	Simplified routine to load nib files for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import	"ClueLoadNib.h"

extern "Objective-C" {
#import	<objc/NXBundle.h>
#import	<appkit/Application.h>
#import	<appkit/Panel.h>
}

extern "C" {
#import	<stdio.h>
#import	<stdlib.h>
}


//-----------------------------------------------------------------------------
// ClueLoadNib
//-----------------------------------------------------------------------------
void ClueLoadNib( id obj )
    {
    char const* name = [[obj class] name];
    char buff[ FILENAME_MAX ];

    if ([[NXBundle mainBundle] getPath:buff forResource:name ofType:"nib"] == 0)
	{
	NXRunAlertPanel( "Fatal", "Cannot locate %s.nib", "OK",0,0, name );
	exit(3);
	}

    if ([NXApp loadNibFile:buff owner:obj withNames:NO] == 0)
	{
	NXRunAlertPanel( "Fatal", "Cannot load %s", "OK",0,0, buff );
	exit(3);
	}
    }
