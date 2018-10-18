#ifndef __ClueBoardView_h
#define __ClueBoardView_h
//-----------------------------------------------------------------------------
// ClueBoardView.h
//
//	Custom view that manages the display of the board and the drag and
//	drop interaction with it.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueBoardView.h,v 1.1 97/05/31 10:07:34 zarnuk Exp $
// $Log:	ClueBoardView.h,v $
//  Revision 1.1  97/05/31  10:07:34  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------

#import <AppKit/NSView.h>
#import "ClueDefs.h"

@class ClueMgr, NSImage;

class ClueMap;

@interface ClueBoardView : NSView
    {
    NSImage* background;
    ClueMgr* clueMgr;
    NSImage* pieces[ CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT ];
    NSImage* fade;
    BOOL dragging;
    ClueCoord dragSource;
    BOOL highlighting;
    ClueCoord highlightCoord;
    bool const* draggable;
    ClueMap const* map;
    id client;
    }

- (instancetype)initWithFrame:(NSRect)rect;
- (void)drawRect:(NSRect)rects;
- (void)setClueMgr:(ClueMgr*)mgr;
- (void) movePiece:(ClueCard)piece
	from:(ClueCoord)old_pos to:(ClueCoord)new_pos;

- (void) allowDrag:(bool const*)pieces map:(ClueMap const*)map
	for:(id)client;

@end

@interface ClueBoardView(Client)
- (void) piece:(ClueCard)piece from:(ClueCoord)oldPos
	droppedAt:(ClueCoord)newPos;
@end

#endif // __ClueBoardView_h
