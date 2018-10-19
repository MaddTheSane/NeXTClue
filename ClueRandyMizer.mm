//-----------------------------------------------------------------------------
// ClueRandyMizer.M
//
//	Clue computer player that chooses random suggestions.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueRandyMizer.M,v 1.1 97/05/31 10:12:04 zarnuk Exp $
// $Log:	ClueRandyMizer.M,v $
//  Revision 1.1  97/05/31  10:12:04  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueRandyMizer.h"


@implementation ClueRandyMizer

- (NSString*) playerName	{ return @"Randy Mizer"; }

//-----------------------------------------------------------------------------
// initPlayer:numPlayers:numCards:cards:piece:location:
//-----------------------------------------------------------------------------
- initWithPlayer:(int)playerID playerCount:(int)numPlayers
       cardCount:(int)numCards cards:(ClueCard const*)i_cards
           piece:(ClueCard)pieceID location:(ClueCoord)i_location
     clueManager:(ClueMgr*)mgr
{
    if (self = [super initWithPlayer:playerID playerCount:numPlayers
                       cardCount:numCards cards:i_cards
                               piece:pieceID location:i_location clueManager:mgr]) {

        for (int i = 0; i < CLUE_ROOM_COUNT; i++) {
            num_choices[i] = CLUE_CHOICE_COUNT;
            for (int j = 0; j < CLUE_CHOICE_COUNT; j++)
                choices[i][j] = j;
        }

        found_solution = NO;
    }

    return self;
}


//-----------------------------------------------------------------------------
// nobodyDisproves:
//-----------------------------------------------------------------------------
- (void) nobodyDisproves:(ClueSolution const*)p
{
    if (my_turn)
    {
        found_solution = YES;
        for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
            if ([self amHoldingCard:p->v[i]])
            { found_solution = NO; break; }
    }
}


//-----------------------------------------------------------------------------
// makeSuggestion
//-----------------------------------------------------------------------------
- (void) makeSuggestion
{
    ClueSolution const* p = 0;
    ClueCard curr_room = ClueRoomAt( [self location] );
    if (curr_room != CLUE_CARD_MAX && curr_room != last_room)
    {
        int const r = curr_room - CLUE_ROOM_FIRST;
        int n = num_choices[r];
        if (n > 0)
        {
            int const m = random_int( n );
            num_choices[r] = --n;
            int k = choices[r][m];
            if (m < n)
                choices[r][m] = choices[r][n];

            int s = k % CLUE_SUSPECT_COUNT;
            int w = k / CLUE_SUSPECT_COUNT;

            suggestion.suspect() = ClueCard( s + int(CLUE_SUSPECT_FIRST) );
            suggestion.weapon()  = ClueCard( w + int(CLUE_WEAPON_FIRST) );
            suggestion.room()    = curr_room;

            p = &suggestion;
        }
    }
    [self suggest:p];
}


//-----------------------------------------------------------------------------
// makeAccusation
//-----------------------------------------------------------------------------
- (void) makeAccusation
{
    ClueSolution* p = 0;
    if (found_solution)
        p = &suggestion;
    [self accuse:p];
}


//-----------------------------------------------------------------------------
// chooseGoalRoom
//	Choose a room that is "close" and for which we have not exhausted
//	our supply of suggestions.
//-----------------------------------------------------------------------------
- (ClueCard) chooseGoalRoom
{
    int n = 0;
    ClueCard buff[ CLUE_ROOM_COUNT ];

    for (int i = 0; i < CLUE_ROOM_COUNT; i++)
        if (num_choices[i] > 0)
            buff[ n++ ] = ClueCard( i + CLUE_ROOM_FIRST );

    return [self chooseClosest:buff count:n];
}


//-----------------------------------------------------------------------------
// wantToStay:
//-----------------------------------------------------------------------------
- (BOOL) wantToStay:(ClueCard)room
{
    int const r = room - CLUE_ROOM_FIRST;
    return num_choices[r] > 0;
}

@end
