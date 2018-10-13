//-----------------------------------------------------------------------------
// ClueButton.M
//
//	Category for the Button class which provides tag-oriented access
//	to popup lists.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import	"ClueButton.h"

extern "Objective-C" {
#import	<appkit/Button.h>
#import	<appkit/ButtonCell.h>
#import	<appkit/Matrix.h>
#import	<appkit/PopUpList.h>
}

@implementation Button(Pop)

- (void) selectTag:(int)x
    {
    Matrix* matrix = [[self target] itemList];
    [matrix selectCellWithTag:x];
    [self setTitle:[[matrix selectedCell] title]];
    }

- (int) selectedTag
    { return [[[[self target] itemList] selectedCell] tag]; }

@end
