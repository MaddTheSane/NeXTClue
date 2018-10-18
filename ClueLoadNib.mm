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
#import <AppKit/NSNibLoading.h>

extern "C" {
#import	<stdio.h>
#import	<stdlib.h>
}


//-----------------------------------------------------------------------------
// ClueLoadNib
//-----------------------------------------------------------------------------
void ClueLoadNib( id obj )
{
    NSString *name = [obj className];
    NSString *buff;

    if ((buff = [[NSBundle mainBundle] pathForResource:name ofType:@"nib"]) == nil)
    {
        NSRunAlertPanel(@"Fatal", @"Cannot locate %@.nib", @"OK", nil, nil, name);
        exit(3);
    }

    if ([NSBundle loadNibNamed:buff owner:obj] == 0)
    {
        NSRunAlertPanel(@"Fatal", @"Cannot load %@", @"OK", nil, nil, buff);
        exit(3);
    }
}
