//-----------------------------------------------------------------------------
// ClueLoadNib.M
//
//	Simplified routine to load nib files for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueLoadNib.M,v 1.1 97/05/31 10:11:18 zarnuk Exp $
// $Log:	ClueLoadNib.M,v $
//  Revision 1.1  97/05/31  10:11:18  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import	"ClueLoadNib.h"

#import	<Foundation/NSBundle.h>
#import	<AppKit/NSApplication.h>
#import	<AppKit/NSPanel.h>

extern "C" {
#import	<stdio.h>
#import	<stdlib.h>
}


//-----------------------------------------------------------------------------
// ClueLoadNib
//-----------------------------------------------------------------------------
void ClueLoadNib( id obj )
    {
    char const* name = [[[obj class] name] cString];
    char buff[ FILENAME_MAX ];

#error StringConversion: This call to -[NXBundle getPath:forResource:ofType:] has been converted to the similar NSBundle method.  The conversion has been made assuming that the variable called buff will be changed into an (NSString *).  You must change the type of the variable called buff by hand.
    if (buff = [[NSBundle mainBundle] pathForResource:[NSString stringWithCString:name] ofType:@"nib"] == 0)
	{
	NSRunAlertPanel(@"Fatal", @"Cannot locate %s.nib", @"OK", nil, nil, name);
	exit(3);
	}

    if ([NSBundle loadNibFile:[NSString stringWithCString:buff] externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:obj, @"NSOwner", nil] withZone:[obj zone]] == 0)
	{
	NSRunAlertPanel(@"Fatal", @"Cannot load %s", @"OK", nil, nil, buff);
	exit(3);
	}
    }
