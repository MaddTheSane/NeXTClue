#ifndef __ClueHuman_h
#define __ClueHuman_h
//-----------------------------------------------------------------------------
// ClueHuman.h
//
//	Human player UI for the Clue app.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueHuman.h,v 1.1 97/05/31 10:09:48 zarnuk Exp Locker: zarnuk $
// $Log:	ClueHuman.h,v $
//  Revision 1.1  97/05/31  10:09:48  zarnuk
//  v21
//-----------------------------------------------------------------------------
#import	"CluePlayer.h"

@class Button, Matrix, Text, TextField, Window;
@class MiscTableScroll;
class ClueMap;

@interface ClueHuman:CluePlayer
	{
	Window*		window;
	MiscTableScroll* scroll;
	TextField*	messageField;
	Matrix*		revealMatrix;
	Button*		stayButton;
	Button*		passageButton;
	Button*		rollButton;
	Button*		dieButton;
	Button*		revealButton;
	Button*		suspectPop;
	Button*		weaponPop;
	Button*		roomPop;
	Button*		skipButton;
	Button*		suggestButton;
	Button*		accuseButton;
	Text*		fieldEditor;
	ClueMap*	map;
	ClueSolution	suggestion;
	ClueCard	currRoom;
	ClueCard	passageRoom;
	ClueCard	suspectID;
	ClueCard	weaponID;
	ClueCoord	suspectPos;	// Saved position before transferring.
	ClueCoord	weaponPos;
	bool		draggable[ CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT ];
	BOOL		forAccuse;
	BOOL		forMove;
	BOOL		wasDisproved;
	}

- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)cards
	piece:(ClueCard)pieceID location:(ClueCoord)location
	clueMgr:(ClueMgr*)mgr;

- (BOOL) isHuman;

// DIALOGUE MESSAGES
- (void) player:(int)playerID reveals:(ClueCard)card;
- (void) disprove:(ClueSolution const*)solution forPlayer:(int)playerID;
- (void) makeMove;
- (void) makeSuggestion;
- (void) makeAccusation;
@end

#endif // __ClueHuman_h
