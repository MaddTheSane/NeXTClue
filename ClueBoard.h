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
// $Id: ClueBoard.h,v 1.1 97/05/31 10:06:55 zarnuk Exp $
// $Log:	ClueBoard.h,v $
//  Revision 1.1  97/05/31  10:06:55  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <Foundation/NSObject.h>
}
#import "ClueDefs.h"
@class ClueBoardView, ClueMgr, NSWindow;

@interface ClueBoard : NSObject
    {
    ClueBoardView* boardView;
    ClueMgr* clueMgr;
    NSWindow* window;
    }

- (id)initWithMgr:(ClueMgr*)mgr;
- (void)dealloc;
- (void)orderFront;
- (void)movePiece:(ClueCard)piece
	from:(ClueCoord)old_pos to:(ClueCoord)new_pos;
- (ClueBoardView*)boardView;

@end

#endif // __ClueBoard_h
