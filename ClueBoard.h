#ifndef __ClueBoard_h
#define __ClueBoard_h
//-----------------------------------------------------------------------------
// ClueBoard.h
//
//	Object responsible for managing the board for the Clue game.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <objc/Object.h>
}
#import "ClueDefs.h"
@class ClueBoardView, ClueMgr, Window;

@interface ClueBoard : Object
    {
    ClueBoardView* boardView;
    ClueMgr* clueMgr;
    Window* window;
    }

- (id)initWithMgr:(ClueMgr*)mgr;
- (id)free;
- (void)orderFront;
- (void)movePiece:(ClueCard)piece
	from:(ClueCoord)old_pos to:(ClueCoord)new_pos;
- (ClueBoardView*)boardView;

@end

#endif // __ClueBoard_h
