//-----------------------------------------------------------------------------
// ClueMessages.M
//
//	Panel displaying a trace of messages for the Clue game.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueMessages.h"
#import "ClueTrace.h"
#import	"ClueLoadNib.h"

extern "Objective-C" {
#import <appkit/Text.h>
#import <appkit/Panel.h>
}


@implementation ClueMessages

//-----------------------------------------------------------------------------
// print:
//-----------------------------------------------------------------------------
- (id) print: (id) sender
    {
    [text printPSCode:self];
    return self;
    }


//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- free
    {
    [trace free];
    [window close];
    [window free];
    return [super free];
    }


//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------
- init
    {
    [super init];
    ClueLoadNib( self );
    [window setWorksWhenModal:YES];
    [window setFrameAutosaveName:"MessagesWindow"];
    trace = [[ClueTrace alloc] initText:text];
    return self;
    }


//-----------------------------------------------------------------------------
// orderFront:
//-----------------------------------------------------------------------------
- orderFront:sender
    {
    [window orderFront:sender];
    return self;
    }


- (ClueTrace*) getTrace		{ return trace; }

@end
