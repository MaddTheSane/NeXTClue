//-----------------------------------------------------------------------------
// ClueBaord.h
//
//	Object responsible for managing the board for the Clue game.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueBoard.h"
#import "ClueBoardView.h"
#import "ClueLoadNib.h"
extern "Objective-C" {
#import <appkit/Window.h>
}

@implementation ClueBoard

- (ClueBoardView*) boardView { return boardView; }
- (void) orderFront { [window orderFront:self]; }
- (id) print:(id)sender { [boardView printPSCode:self]; return self; }

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
    [window setFrameAutosaveName:"ClueBoard"];
    return self;
    }


//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- (id)free
    {
    [window close];
    [window free];
    return [super free];
    }

@end
