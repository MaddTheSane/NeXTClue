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
// $Id: ClueRandyMizer.h,v 1.1 97/05/31 10:12:08 zarnuk Exp $
// $Log:	ClueRandyMizer.h,v $
//  Revision 1.1  97/05/31  10:12:08  zarnuk
//  v21
//  
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

- (instancetype)initWithPlayer:(int)playerID playerCount:(int)numPlayers
                     cardCount:(int)numCards cards:(ClueCard const*)cards
                         piece:(ClueCard)pieceID location:(ClueCoord)location
                   clueManager:(ClueMgr*)mgr;

- (void) nobodyDisproves:(ClueSolution const*)buff;

- (void) makeSuggestion;
- (void) makeAccusation;

- (ClueCard) chooseGoalRoom;
- (BOOL) wantToStay:(ClueCard)room;

@end

#endif // __ClueRandyMizer_h
