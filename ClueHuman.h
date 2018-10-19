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
#import <Cocoa/Cocoa.h>

@class MiscTableScroll;
class ClueMap;

@interface ClueHuman:CluePlayer
{
    IBOutlet NSWindow*		window;
    IBOutlet MiscTableScroll* scroll;
    IBOutlet NSTextField*	messageField;
    IBOutlet NSMatrix*		revealMatrix;
    IBOutlet NSButton*		stayButton;
    IBOutlet NSButton*		passageButton;
    IBOutlet NSButton*		rollButton;
    IBOutlet NSButton*		dieButton;
    IBOutlet NSButton*		revealButton;
    IBOutlet NSPopUpButton*	suspectPop;
    IBOutlet NSPopUpButton*	weaponPop;
    IBOutlet NSPopUpButton*	roomPop;
    IBOutlet NSButton*		skipButton;
    IBOutlet NSButton*		suggestButton;
    IBOutlet NSButton*		accuseButton;
    IBOutlet NSText*		fieldEditor;
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

- (instancetype)initWithPlayer:(int)playerID playerCount:(int)numPlayers
                     cardCount:(int)numCards cards:(ClueCard const*)cards
                         piece:(ClueCard)pieceID location:(ClueCoord)location
                   clueManager:(ClueMgr*)mgr;

- (BOOL) isHuman;

// DIALOGUE MESSAGES
- (void) player:(int)playerID reveals:(ClueCard)card;
- (void) disprove:(ClueSolution const*)solution forPlayer:(int)playerID;
- (void) makeMove;
- (void) makeSuggestion;
- (void) makeAccusation;
@end

#endif // __ClueHuman_h
