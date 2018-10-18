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
// $Id: ClueComputer.h,v 1.1 97/05/31 10:08:11 zarnuk Exp $
// $Log:	ClueComputer.h,v $
//  Revision 1.1  97/05/31  10:08:11  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "CluePlayer.h"

@interface ClueComputer : CluePlayer

- (instancetype)initWithPlayer:(int)playerID playerCount:(int)numPlayers
                     cardCount:(int)numCards cards:(ClueCard const*)cards
                         piece:(ClueCard)pieceID location:(ClueCoord)location
                   clueManager:(ClueMgr*)mgr;

// Default computer player move mechanism.
- (void) makeMove;

// Subclass interface
- (BOOL) wantToStay:(ClueCard)room;	// Default: YES
- (ClueCard) chooseGoalRoom;		// Default: closest room.

// Subclass utility
- (ClueCard) chooseClosest:(ClueCard const*)rooms count:(int)numRooms;
@end

#endif // __ClueComputer_h
