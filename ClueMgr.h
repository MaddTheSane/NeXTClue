#ifndef __ClueMgr_h
#define __ClueMgr_h
//-----------------------------------------------------------------------------
// ClueMgr.h
//
//	Game manager for the Clue app.
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
#import	"ClueDefs.h"

@class CluePlayer;
@class ClueMessages;
@class ClueTrace;
@class ClueBoard;
@class ClueBoardView;

enum ClueState
	{
	CLUE_STATE_NEW_GAME,		// Starting a new game
	CLUE_STATE_NEXT_PLAYER,		// Waiting for nextPlayerOk:
	CLUE_STATE_MOVE,		// Waiting for move...
	CLUE_STATE_SUGGEST,		// Waiting for suggest:ok:
	CLUE_STATE_REVEAL,		// Waiting for reveal:ok:
	CLUE_STATE_REVEAL_OK,		// Waiting for revealOk:
	CLUE_STATE_ACCUSE,		// Waiting for accuse:ok:
	CLUE_STATE_GAME_OVER
	};


struct CluePlayerRec
	{
	int		player_id;
	ClueCard	piece_id;	// Identifies playing piece.
	ClueCard	last_room;
	int		hand_start;	// Index into deck.
	int		hand_length;
	CluePlayer*	player;
	bool		can_stay;	// Dragged into room by an opponent.
	bool		lost;
	};



@interface ClueMgr : Object
	{
	ClueState state;		// Indicates message that we expect.
	int player_id;			// Current player.
	int query_id;			// Index of waiting_for player.
	CluePlayer* waiting_for;	// Player we are waiting to hear from.
	int num_players;
	ClueBoard* board;
	ClueMessages* messages;
	ClueTrace* trace;
	ClueSolution suggestion;	// Current suggestion / accusation.
	ClueSolution solution;
	ClueCard deck[ CLUE_CARD_COUNT ];
	CluePlayerRec players[ CLUE_NUM_PLAYERS_MAX ];
	ClueCoord locations[ CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT ];
	BOOL stillPlaying;
	}

- newGame:sender;
- showRules:sender;
- appInfo:sender;

- (ClueBoardView*) boardView;
- (ClueCoord) pieceLocation:(ClueCard)piece;
- (ClueCard) pieceAt:(ClueCoord)pos;
- (BOOL) movePiece:(ClueCard)piece to:(ClueCoord)pos;
- (ClueCoord) roomCoord:(ClueCard)room;	// Random, unoccupied cell in room.

- (CluePlayer*) playerForPiece:(ClueCard)piece;
- (int) rollDie;

// DIALOGUE RESPONSE MESSAGES
// [player nextPlayer:x];		// Pause between turns.
- (void) nextPlayerOk:(CluePlayer*)player;

// [player makeMove];
- (void) moveTo:(ClueCoord)coord ok:(CluePlayer*)player;

// [player makeSuggestion];		// Pause to make a suggestion.
- (void) suggest:(ClueSolution const*)x ok:(CluePlayer*)player;

// [player disprove:x forPlayer:y];	// Pause to choose a card to reveal.
- (void) reveal:(ClueCard)card ok:(CluePlayer*)player;

// [player player:x reveals:card];	// Acknowledge revealed card.
- (void) revealOk:(CluePlayer*)player;

// [player makeAccusation];		// Pause to make an accusation.
- (void) accuse:(ClueSolution const*)x ok:(CluePlayer*)player;

@end

#endif // __ClueMgr_h
