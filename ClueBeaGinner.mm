//-----------------------------------------------------------------------------
// ClueBeaGinner.M
//
//	Clue computer player that chooses random suggestions.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueBeaGinner.M,v 1.1 97/05/31 10:07:02 zarnuk Exp $
// $Log:	ClueBeaGinner.M,v $
//  Revision 1.1  97/05/31  10:07:02  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueBeaGinner.h"

extern "C" {
#import	<string.h>	// memmove()
}


@implementation ClueBeaGinner

- (NSString*) playerName	{ return @"Bea Ginner"; }

//-----------------------------------------------------------------------------
// init_category::::::
//-----------------------------------------------------------------------------
- (void) init_category:(ClueCard)lo :(ClueCard)hi
		:(int*)n :(ClueCard*)v		// NOT holding
		:(int*)m :(ClueCard*)w		// HOLDING
{
    int vn = 0;
    int wm = 0;
    for (unsigned int i = lo; i <= hi; i++)
    {
        ClueCard const x = ClueCard(i);
        if ([self amHoldingCard:x])
            w[ wm++ ] = x;
        else
            v[ vn++ ] = x;
    }
    *n = vn;
    *m = wm;
}


//-----------------------------------------------------------------------------
// initPlayer:numPlayers:numCards:cards:piece:location:
//-----------------------------------------------------------------------------
- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)i_cards
	piece:(ClueCard)pieceID location:(ClueCoord)i_location
	clueMgr:(ClueMgr*)mgr
{
    [super initPlayer:playerID numPlayers:numPlayers
             numCards:numCards cards:i_cards
                piece:pieceID location:i_location clueMgr:mgr];

    [self init_category: CLUE_SUSPECT_FIRST : CLUE_SUSPECT_LAST
                       :&num_suspects :suspects
                       :&num_held_suspects :held_suspects];

    [self init_category: CLUE_WEAPON_FIRST : CLUE_WEAPON_LAST
                       :&num_weapons :weapons
                       :&num_held_weapons :held_weapons];

    [self init_category: CLUE_ROOM_FIRST : CLUE_ROOM_LAST
                       :&num_rooms :rooms
                       :&num_held_rooms :held_rooms];

    return self;
}


//-----------------------------------------------------------------------------
// solved_check:::
//-----------------------------------------------------------------------------
- (void) solved_check:(ClueCard)x :(int*)n :(ClueCard*)v
{
    if (![self amHoldingCard:x])
    {
        *n = 1;
        v[0] = x;
    }
}


//-----------------------------------------------------------------------------
// nobodyDisproves:
//-----------------------------------------------------------------------------
- (void) nobodyDisproves:(ClueSolution const*)p
{
    if (my_turn)
    {
        [self solved_check: p->suspect() :&num_suspects :suspects];
        [self solved_check: p->weapon() :&num_weapons :weapons];
        [self solved_check: p->room() :&num_rooms :rooms];
    }
}


//-----------------------------------------------------------------------------
// check:list:count:
//-----------------------------------------------------------------------------
- (void) check:(ClueCard)x list:(ClueCard*)list count:(int*)count
{
    int lim = *count;
    for (int i = 0; i < lim; i++)
        if (list[i] == x)
        {
            *count = --lim;
            if (i < lim)
                memmove( list + i, list + i + 1, (lim - i) * sizeof(*list) );
        }
}


//-----------------------------------------------------------------------------
// player:reveals:
//-----------------------------------------------------------------------------
- (void) player:(int)playerID reveals:(ClueCard)card
{
    [self check:card list:suspects count:&num_suspects];
    [self check:card list:weapons count:&num_weapons];
    [self check:card list:rooms count:&num_rooms];
    [self revealOk];
}


//-----------------------------------------------------------------------------
// choose::::
//	'x' is a list of unknown cards for the current category.
//	'y' is a list of cards this player holds for that category.
//-----------------------------------------------------------------------------
- (ClueCard) choose:(ClueCard const*)x :(int)nx :(ClueCard const*)y :(int)ny
{
    BOOL from_x = YES;

    if (ny != 0)
    {
        if (nx == 1)
            from_x = (random_int( ny + 1 ) == 1);
        else
            from_x = (random_int( 4 ) < 3);	// 3-to-1 bias in favor of 'x'.
    }

    ClueCard choice;
    if (from_x)
        choice = x[ random_int(nx) ];
    else
        choice = y[ random_int(ny) ];

    return choice;
}


//-----------------------------------------------------------------------------
// makeSuggestion
//-----------------------------------------------------------------------------
- (void) makeSuggestion
{
    ClueSolution* p = 0;
    ClueCard const curr_room = ClueRoomAt( [self location] );
    if (curr_room != CLUE_CARD_MAX && curr_room != last_room)
    {
        p = &solution_buff;
        p->suspect() = [self choose:suspects:num_suspects
                                   :held_suspects:num_held_suspects];
        p->weapon() = [self choose:weapons:num_weapons
                                  :held_weapons:num_held_weapons];
        p->room() = curr_room;
    }
    [self suggest:p];
}


//-----------------------------------------------------------------------------
// makeAccusation
//-----------------------------------------------------------------------------
- (void) makeAccusation
{
    ClueSolution* p = 0;
    if (num_suspects == 1 && num_weapons == 1 && num_rooms == 1)
    {
        p = &solution_buff;
        p->suspect() = suspects[0];
        p->weapon() = weapons[0];
        p->room() = rooms[0];
    }
    [self accuse:p];
}


//-----------------------------------------------------------------------------
// find:::
//-----------------------------------------------------------------------------
- (BOOL) find:(ClueCard)x :(ClueCard const*)v :(int)n
{
    for (int i = 0; i < n; i++)
        if (v[n] == x)
            return YES;
    return NO;
}


//-----------------------------------------------------------------------------
// wantToStay:
//	We want to stay in this room to make a suggestion if this is an
//	unknown room, or if we have not solved the suspect and/or weapon
//	category and we hold this room.
//-----------------------------------------------------------------------------
- (BOOL) wantToStay:(ClueCard) room
{
    return [self find:room :rooms :num_rooms] ||
    ((num_suspects > 1 || num_weapons > 1) &&
     [self find:room :held_rooms :num_held_rooms]);
}


//-----------------------------------------------------------------------------
// chooseGoalRoom
//-----------------------------------------------------------------------------
- (ClueCard) chooseGoalRoom
{
    int i;
    int n = 0;
    ClueCard buff[ CLUE_ROOM_COUNT ];
    
    for (i = 0; i < num_rooms; i++)
        buff[n++] = rooms[i];
    
    if (num_suspects > 1 || num_weapons > 1)
        for (i = 0; i < num_held_rooms; i++)
            buff[n++] = held_rooms[i];
    
    return [self chooseClosest:buff count:n];
}

@end
