//-----------------------------------------------------------------------------
// ClueMessages.M
//
//	Panel displaying a trace of messages for the Clue game.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueMessages.M,v 1.1 97/05/31 10:11:03 zarnuk Exp $
// $Log:	ClueMessages.M,v $
//  Revision 1.1  97/05/31  10:11:03  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueMessages.h"
#import "ClueTrace.h"
#import	"ClueLoadNib.h"

#import <AppKit/NSText.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSPanel.h>


@implementation ClueMessages

//-----------------------------------------------------------------------------
// print:
//-----------------------------------------------------------------------------
#warning PrintingConversion:  printPSCode: has been renamed to print:.  Rename this method?
- (void)print:(id)sender
{
    [text print:self];
}


//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- (void)dealloc
{
    [trace release];
    [window close];
    [window release];
    { [super dealloc]; return; };
}


//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------
- init
{
    self = [super init];
    ClueLoadNib( self );
    [window setWorksWhenModal:YES];
    [window setFrameAutosaveName:@"MessagesWindow"];
    trace = [[ClueTrace alloc] initWithText:text];
    return self;
}


//-----------------------------------------------------------------------------
// orderFront:
//-----------------------------------------------------------------------------
- (void)orderFront:(id)sender
{
    [window orderFront:sender];
}


- (ClueTrace*) getTrace		{ return trace; }

@end
