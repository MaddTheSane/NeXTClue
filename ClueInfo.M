//-----------------------------------------------------------------------------
// ClueInfo.h
//
//	Info panel for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueInfo.M,v 1.2 97/05/31 14:05:50 zarnuk Exp Locker: zarnuk $
// $Log:	ClueInfo.M,v $
//  Revision 1.2  97/05/31  14:05:50  zarnuk
//  v21: Now reads version number from PACKAGE_NUMBER file.
//  
//  Revision 1.1  97/05/31  10:10:48  zarnuk
//-----------------------------------------------------------------------------
#import "ClueInfo.h"
#import "ClueLoadNib.h"

extern "Objective-C" {
#import	<appkit/TextField.h>
#import	<appkit/Panel.h>	// NXRunAlertPanel(), Window
#import	<objc/NXBundle.h>
}

extern "C" {
#import	<stdio.h>		// FILENAME_MAX, fopen(), etc.
#import	<stdlib.h>		// exit()
}


static char const PKGFILE[] = "PACKAGE_NUMBER";

@implementation ClueInfo

- init
    {
    [super init];
    ClueLoadNib( self );

    char const* ver = "find pkg#";

    char buff[ FILENAME_MAX ];
    if ([[NXBundle mainBundle] getPath:buff forResource:PKGFILE ofType:""])
	{
	FILE* fp;
	if ((fp = fopen( buff, "r" )) != 0)
	    {
	    int n;
	    if (fscanf( fp, "%d", &n ) == 1)
		{
		sprintf( buff, "v%d", n );
		ver = buff;
		}
	    else
		ver = "parse pkg#";
	    fclose( fp );
	    }
	else
	    ver = "open pkg#";
	}

    [versionField setStringValue:ver];

    return self;
    }


- makeKeyAndOrderFront:sender
    {
    return [window makeKeyAndOrderFront:sender];
    }


+ launch
    {
    static ClueInfo* instance = 0;
    if (instance == 0)
	instance = [[self alloc] init];
    [instance makeKeyAndOrderFront:self];
    return self;
    }

@end
