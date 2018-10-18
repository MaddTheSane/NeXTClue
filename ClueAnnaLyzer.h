#ifndef __ClueAnnaLyzer_h
#define __ClueAnnaLyzer_h
//-----------------------------------------------------------------------------
// ClueAnnaLyzer.h
//
//	Clue computer player that analyzes revelations.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueAnnaLyzer.h,v 1.1 97/05/31 10:06:19 zarnuk Exp $
// $Log:	ClueAnnaLyzer.h,v $
//  Revision 1.1  97/05/31  10:06:19  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueComputer.h"

class ClueUpdateStack;
class ClueCardPicker;


enum	{			// grid[][] values.
	GRID_BLANK = 0,		// No information on this card.
	GRID_NOT_HOLDS,		// Definitely doesn't hold this card.
	GRID_HOLDS,		// Definitely holds this card.
	};


int const PLAYER_UNKNOWN = -1;	// card_to_player[] special values
int const PLAYER_SOLUTION = -2;


@interface ClueAnnaLyzer : ClueComputer
{
    int num_dealt[ CLUE_NUM_PLAYERS_MAX ];
    int num_known[ CLUE_NUM_PLAYERS_MAX ];
    int grid[ CLUE_NUM_PLAYERS_MAX ][ CLUE_CARD_MAX ];
    int card_to_player[ CLUE_CARD_MAX ];
    int revealed[ CLUE_CARD_MAX ];
    ClueSolution solution;
    ClueSolution suggestion;
    int suggestor_id;		// Player making current suggestion.
}

- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)cards
	   piece:(ClueCard)pieceID location:(ClueCoord)location
	 clueMgr:(ClueMgr*)mgr;

- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)buff;
- (void) player:(int)playerID reveals:(ClueCard)card;
- (void) disprove:(ClueSolution const*)solution forPlayer:(int)playerID;

- (void) makeSuggestion;
- (void) makeAccusation;

// SUBCLASS HOOKS
- (void) dump;
- (void) stack:(ClueUpdateStack*)stack player:(int)p holdsCard:(ClueCard)c;
- (void) stack:(ClueUpdateStack*)stack player:(int)p notHoldsCard:(ClueCard)c;
- (void) earlyInit;
- (void) lateInit;
- (void) player:(int)player holds:(BOOL)holds card:(ClueCard)card;
- (int) scoreUnknown:(int)card;

@end

#endif // __ClueAnnaLyzer_h
