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
// $Id$
// $Log$
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <appkit/View.h>
}
#import "ClueDefs.h"
@class ClueMgr, NXImage;

class ClueMap;

@interface ClueBoardView : View
    {
    NXImage* background;
    ClueMgr* clueMgr;
    NXImage* pieces[ CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT ];
    NXImage* fade;
    BOOL dragging;
    ClueCoord dragSource;
    BOOL highlighting;
    ClueCoord highlightCoord;
    bool const* draggable;
    ClueMap const* map;
    id client;
    }

- (id)initFrame:(NXRect const*)rect;
- (id)free;
- (id)drawSelf:(NXRect const*)rects :(int)nrects;
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
