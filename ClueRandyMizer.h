#ifndef __ClueRandyMizer_h
#define __ClueRandyMizer_h
//-----------------------------------------------------------------------------
// ClueRandyMizer.h
//
//	Clue computer player that chooses random suggestions.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueComputer.h"

int const CLUE_CHOICE_COUNT = CLUE_SUSPECT_COUNT * CLUE_WEAPON_COUNT;

@interface ClueRandyMizer : ClueComputer
	{
	int num_choices[ CLUE_ROOM_COUNT ];
	int choices[ CLUE_ROOM_COUNT ][ CLUE_CHOICE_COUNT ];
	ClueSolution suggestion;
	BOOL found_solution;
	}

- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)cards
	piece:(ClueCard)pieceID location:(ClueCoord)location
	clueMgr:(ClueMgr*)mgr;

- (void) nobodyDisproves:(ClueSolution const*)buff;

- (void) makeSuggestion;
- (void) makeAccusation;

- (ClueCard) chooseGoalRoom;
- (BOOL) wantToStay:(ClueCard)room;

@end

#endif // __ClueRandyMizer_h
