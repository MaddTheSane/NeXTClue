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
// $Id: ClueHuman.h,v 1.2 97/09/21 01:27:27 zarnuk Exp $
// $Log:	ClueHuman.h,v $
//  Revision 1.2  97/09/21  01:27:27  zarnuk
//  v25 -- Converted to Misc version of table scroll.
//  
//  Revision 1.1  97/05/31  10:09:48  zarnuk
//  v21
//-----------------------------------------------------------------------------
#import	"CluePlayer.h"

@class NSButton, NSMatrix, NSText, NSTextField, NSWindow;
@class MiscTableScroll;
class ClueMap;

@interface ClueHuman:CluePlayer
	{
	NSWindow*		window;
	MiscTableScroll* scroll;
	NSTextField*	messageField;
	NSMatrix*		revealMatrix;
	NSButton*		stayButton;
	NSButton*		passageButton;
	NSButton*		rollButton;
	NSButton*		dieButton;
	NSButton*		revealButton;
	NSButton*		suspectPop;
	NSButton*		weaponPop;
	NSButton*		roomPop;
	NSButton*		skipButton;
	NSButton*		suggestButton;
	NSButton*		accuseButton;
	NSText*		fieldEditor;
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
