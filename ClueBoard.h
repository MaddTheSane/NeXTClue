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

#import <Cocoa/Cocoa.h>
#import "ClueDefs.h"

@class ClueBoardView, ClueMgr;

@interface ClueBoard : NSObject
{
    IBOutlet ClueBoardView* boardView;
    ClueMgr* clueMgr;
    IBOutlet NSWindow* window;
}

- (id)initWithMgr:(ClueMgr*)mgr;
- (void)orderFront;
- (void)movePiece:(ClueCard)piece
             from:(ClueCoord)old_pos to:(ClueCoord)new_pos;
- (ClueBoardView*)boardView;

@end

#endif // __ClueBoard_h
