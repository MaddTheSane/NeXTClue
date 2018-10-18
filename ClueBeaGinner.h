#ifndef __ClueBeaGinner_h
#define __ClueBeaGinner_h
//-----------------------------------------------------------------------------
// ClueBeaGinner.h
//
//	Clue computer player that approximates the playing strategy
//	of a beginning-level human player.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueBeaGinner.h,v 1.1 97/05/31 10:07:06 zarnuk Exp $
// $Log:	ClueBeaGinner.h,v $
//  Revision 1.1  97/05/31  10:07:06  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueComputer.h"

@interface ClueBeaGinner : ClueComputer
{
    int num_suspects;
    int num_weapons;
    int num_rooms;
    ClueCard suspects[ CLUE_SUSPECT_COUNT ];
    ClueCard weapons[ CLUE_WEAPON_COUNT ];
    ClueCard rooms[ CLUE_ROOM_COUNT ];
    int num_held_suspects;
    int num_held_weapons;
    int num_held_rooms;
    ClueCard held_suspects[ CLUE_SUSPECT_COUNT ];
    ClueCard held_weapons[ CLUE_WEAPON_COUNT ];
    ClueCard held_rooms[ CLUE_ROOM_COUNT ];
    ClueSolution solution_buff;
}

- (instancetype)initWithPlayer:(int)playerID playerCount:(int)numPlayers
                     cardCount:(int)numCards cards:(ClueCard const*)cards
                         piece:(ClueCard)pieceID location:(ClueCoord)location
                   clueManager:(ClueMgr*)mgr;

- (void) nobodyDisproves:(ClueSolution const*)buff;
- (void) player:(int)playerID reveals:(ClueCard)card;

- (void) makeSuggestion;
- (void) makeAccusation;

@end

#endif // __ClueBeaGinner_h
