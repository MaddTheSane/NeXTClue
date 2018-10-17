#ifndef __CluePlayer_h
#define __CluePlayer_h
//-----------------------------------------------------------------------------
// CluePlayer.h
//
//	Base class for player objects in the Clue app.
//
// NOTE *1*
//	These methods maintain the "can_stay" and "last_room" variables.
//	These methods must execute.  If you override them in your subclass,
//	call the super method at the end of your method.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: CluePlayer.h,v 1.1 97/05/31 10:12:18 zarnuk Exp $
// $Log:	CluePlayer.h,v $
//  Revision 1.1  97/05/31  10:12:18  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <Foundation/NSObject.h>
}
#import	"ClueDefs.h"

@class ClueMgr;

@interface CluePlayer : NSObject
	{
	int		player_id;
	int		num_players;
	int		num_cards;
	ClueCard	cards[ CLUE_NUM_CARDS_MAX ];
	ClueCard	piece_id;
	ClueCoord	location;
	ClueMgr*	clueMgr;
	ClueCard	last_room;	// Room at end of last turn.
	BOOL		my_turn;	// This player's turn.
	BOOL		can_stay;	// Can stay and make suggestion.
@private
	ClueCard	cp_card;
	ClueCoord	cp_coord;
	ClueSolution*	cp_solution_ptr;
	ClueSolution	cp_solution_buff;
	}

- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)cards
	piece:(ClueCard)pieceID location:(ClueCoord)location
	clueMgr:(ClueMgr*)clueMgr;

- (int) playerID;
- (int) numPlayers;
- (int) numCards;
- (ClueCard const*) cards;
- (ClueCard) pieceID;
- (ClueCoord) location;
- (ClueMgr*) clueMgr;
- (char const*) playerName;

- (BOOL) canAccuse;		// Default = YES.
- (BOOL) canSuggest;		// Default = YES.
- (BOOL) isHuman;		// Default = NO.

- (BOOL) amHoldingCard:(ClueCard)card;

// DIALOGUE RESPONSE MECHANISM
- (void) nextPlayerOk;
- (void) moveTo:(ClueCoord)coord;
- (void) revealOk;
- (void) reveal:(ClueCard)x;			// CLUE_CARD_MAX for blank.
- (void) suggest:(ClueSolution const*)x;	// x == 0 -> means skip.
- (void) accuse:(ClueSolution const*)x;		// x == 0 -> means skip.

//--------------------//
// SUBCLASS INTERFACE //	// Override these methods in your subclass.
//--------------------//

// NOTIFICATION MESSAGES -- No pause allowed, must return immediately.
- (void) newLocation:(ClueCoord)coord;
- (void) player:(int)playerID accuses:(ClueSolution const*)buff wins:(BOOL)wins;
- (void) player:(int)playerID suggests:(ClueSolution const*)buff; // NOTE *1*
- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)buff;
- (void) player:(int)playerID disproves:(ClueSolution const*)buff;
- (void) nobodyDisproves:(ClueSolution const*)buff;

// DIALOGUE MESSAGES -- Do not return.  Call the method shown below.
- (void) nextPlayer:(int)playerID;	// NOTE *1*
// [self nextPlayerOk];

- (void) makeMove;
// [self moveTo:coord];

- (void) makeSuggestion;		// Pause to get user suggestion.
// [self suggest:p];

- (void) disprove:(ClueSolution const*)solution forPlayer:(int)playerID;
// [self reveal:card];			// Pause to choose card to reveal.

- (void) player:(int)playerID reveals:(ClueCard)card;
// [self revealOk];			// Pause to inspect revealed card.

- (void) makeAccusation;
// [self accuse:p];			// Pause to get user accusation.

@end

#endif // __CluePlayer_h
