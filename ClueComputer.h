#ifndef __ClueComputer_h
#define __ClueComputer_h
//-----------------------------------------------------------------------------
// ClueComputer.h
//
//	Base class for computer players for the Clue app.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "CluePlayer.h"

@interface ClueComputer : CluePlayer
	{
	}

- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)cards
	piece:(ClueCard)pieceID location:(ClueCoord)location
	clueMgr:(ClueMgr*)mgr;

// Default computer player move mechanism.
- (void) makeMove;

// Subclass interface
- (BOOL) wantToStay:(ClueCard)room;	// Default: YES
- (ClueCard) chooseGoalRoom;		// Default: closest room.

// Subclass utility
- (ClueCard) chooseClosest:(ClueCard const*)rooms count:(int)numRooms;
@end

#endif // __ClueComputer_h