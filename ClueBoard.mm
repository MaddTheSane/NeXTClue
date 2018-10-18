//-----------------------------------------------------------------------------
// ClueBaord.h
//
//	Object responsible for managing the board for the Clue game.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueBoard.M,v 1.1 97/05/31 10:06:46 zarnuk Exp $
// $Log:	ClueBoard.M,v $
//  Revision 1.1  97/05/31  10:06:46  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueBoard.h"
#import "ClueBoardView.h"
#import "ClueLoadNib.h"
#import <AppKit/NSWindow.h>

@implementation ClueBoard

- (ClueBoardView*) boardView { return boardView; }
- (void) orderFront { [window orderFront:self]; }
#warning PrintingConversion:  printPSCode: has been renamed to print:.  Rename this method?
- (void)print:(id)sender { [boardView print:self];
}

//-----------------------------------------------------------------------------
// movePiece:from:to:
//-----------------------------------------------------------------------------
- (void)movePiece:(ClueCard)piece
    from:(ClueCoord)old_pos to:(ClueCoord)new_pos
{
    [boardView movePiece:piece from:old_pos to:new_pos];
}


//-----------------------------------------------------------------------------
// initWithMgr:
//-----------------------------------------------------------------------------
- (id)initWithMgr:(ClueMgr*)mgr
{
    [super init];
    clueMgr = mgr;
    ClueLoadNib( self );
    [boardView setClueMgr:mgr];
    [window setFrameAutosaveName:@"ClueBoard"];
    return self;
}


//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- (void)dealloc
{
    [window close];
    [window release];
    { [super dealloc]; return; };
}

@end
