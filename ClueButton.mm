//-----------------------------------------------------------------------------
// ClueButton.M
//
//	Category for the Button class which provides tag-oriented access
//	to popup lists.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueButton.M,v 1.1 97/05/31 10:07:22 zarnuk Exp $
// $Log:	ClueButton.M,v $
//  Revision 1.1  97/05/31  10:07:22  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import	"ClueButton.h"

#import	<AppKit/NSButton.h>
#import	<AppKit/NSButtonCell.h>
#import	<AppKit/NSMatrix.h>
#import	<AppKit/NSPopUpButton.h>

@implementation NSButton(Pop)

- (void) selectTag:(int)x
    {
#warning PopUpConversion: Consider NSPopUpButton methods instead of using itemMatrix to access items in a pop-up list.
    NSMatrix* matrix = [self itemMatrix];
    [matrix selectCellWithTag:x];
    [self setTitle:[[matrix selectedCell] title]];
    }

- (int) selectedTag
#warning PopUpConversion: Consider NSPopUpButton methods instead of using itemMatrix to access items in a pop-up list.
    { return [[[self itemMatrix] selectedCell] tag]; }

@end
