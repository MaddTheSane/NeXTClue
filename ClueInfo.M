//-----------------------------------------------------------------------------
// ClueInfo.h
//
//	Info panel for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueInfo.h"
#import "ClueLoadNib.h"

extern "Objective-C" {
#import	<appkit/Window.h>
}


@implementation ClueInfo

- init
    {
    [super init];
    ClueLoadNib( self );
    return self;
    }


- orderFront:sender
    {
    return [window orderFront:sender];
    }


+ launch
    {
    static ClueInfo* instance = 0;
    if (instance == 0)
	instance = [[self alloc] init];
    [instance orderFront:self];
    return self;
    }

@end
