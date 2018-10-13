//-----------------------------------------------------------------------------
// ClueComputer.M
//
//	Base class for computer players for the Clue app.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueComputer.h"
#import	"ClueCardPicker.h"
#import	"ClueCoordArray.h"
#import	"ClueMap.h"
#import	"ClueMgr.h"

extern "C" {
#import	<assert.h>
#import	<limits.h>	// INT_MAX
}

@implementation ClueComputer
//-----------------------------------------------------------------------------
// initPlayer:numPlayers:numCards:cards:piece:location:clueMgr:
//-----------------------------------------------------------------------------
- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)i_cards
	piece:(ClueCard)pieceID location:(ClueCoord)i_location
	clueMgr:(ClueMgr*)mgr
    {
    [super initPlayer:playerID numPlayers:numPlayers
		numCards:numCards cards:i_cards
		piece:pieceID location:i_location clueMgr:mgr];

    last_room = ClueRoomAt( [self location] );
    my_turn   = NO;
    can_stay  = NO;

    return self;
    }


//-----------------------------------------------------------------------------
// wantToStay:
//-----------------------------------------------------------------------------
- (BOOL) wantToStay:(ClueCard)room
    {
    return YES;
    }


//-----------------------------------------------------------------------------
// chooseClosest:count:
//-----------------------------------------------------------------------------
- (ClueCard) chooseClosest:(ClueCard const*)rooms count:(int)numRooms
    {
    int i;
    ClueCoordArray obstacles;
    int const self_piece = int( [self pieceID] );
    for (i = 0; i < CLUE_SUSPECT_COUNT; i++)
	if (i != self_piece)
	    obstacles.append( [clueMgr pieceLocation:ClueCard(i)] );

    ClueCoord const start_pos = [self location];
    ClueCard const start_room = ClueRoomAt( start_pos );

    int distance[ CLUE_ROOM_COUNT ];
    ClueMap map;
    map.calcDistance( distance, start_pos, obstacles );

    if (start_room != CLUE_CARD_MAX)
	{
	distance[ start_room - CLUE_ROOM_FIRST ] = INT_MAX;
	ClueCard const passage_room = CluePassage( start_room );
	if (passage_room != CLUE_CARD_MAX)
	    distance[ passage_room - CLUE_ROOM_FIRST ] = 0;
	}

    ClueCardPicker picker;
    for (i = 0; i < numRooms; i++)
	{
	ClueCard const x = rooms[i];
	int const j = x - CLUE_ROOM_FIRST;
	picker.add( 0 - distance[j], x );
	}

    return picker.choose();
    }


//-----------------------------------------------------------------------------
// chooseGoalRoom
//-----------------------------------------------------------------------------
- (ClueCard) chooseGoalRoom
    {
    ClueCard rooms[ CLUE_ROOM_COUNT ];
    for (int i = 0; i < CLUE_ROOM_COUNT; i++)
	rooms[i] = ClueCard( i + CLUE_ROOM_FIRST );

    return [self chooseClosest:rooms count:CLUE_ROOM_COUNT];
    }


//-----------------------------------------------------------------------------
// makeMove
//-----------------------------------------------------------------------------
- (void) makeMove
    {
    ClueCoord const curr_pos = [self location];
    ClueCard const curr_room = ClueRoomAt( curr_pos );
    ClueCoord dest = curr_pos;
    ClueCard goal_room;

    if (can_stay && [self wantToStay:curr_room] ||
	(goal_room = [self chooseGoalRoom]) == CLUE_CARD_MAX)
	dest = curr_pos;

    else
	{
	assert( goal_room != CLUE_CARD_MAX );
	assert( CLUE_ROOM_FIRST <= goal_room );
	assert( goal_room <= CLUE_ROOM_LAST );
	ClueCoord const goal_pos = [clueMgr roomCoord:goal_room];

	if (CluePassage( curr_room ) == goal_room)
	    dest = goal_pos;	// Take passage.

	else
	    {
	    ClueCoordArray obstacles;
	    int const self_piece = int( [self pieceID] );
	    for (int i = 0; i < CLUE_SUSPECT_COUNT; i++)
		if (i != self_piece)
		    obstacles.append( [clueMgr pieceLocation:ClueCard(i)] );

	    int rooms[ CLUE_ROOM_COUNT ];
	    ClueMap map;
	    map.calcDistance( rooms, goal_pos, obstacles );

	    int const die_roll = [clueMgr rollDie];
	    ClueMap legal;
	    legal.calcLegal( die_roll, curr_pos, obstacles );

	    if (legal.isLegal( goal_pos ))
		dest = goal_pos;	// Made it with this die roll.
	    else
		{
		int min_distance = INT_MAX;
		ClueCoordArray list;

		for (int r = 0; r < CLUE_ROW_MAX; r++)
		    for (int c = 0; c < CLUE_COL_MAX; c++)
			{
			ClueCoord const pos = { r, c };
			if (legal.isLegal( pos ))
			    {
			    int const dist = map.distanceAt( pos );
			    if (min_distance > dist)
				{
				min_distance = dist;
				list.empty();
				list.append( pos );
				}
			    else if (min_distance == dist)
				list.append( pos );
			    }
			}
		int const n = list.count();
		if (n > 0)
		    dest = list[ random_int(n) ];
		else
		    dest = curr_pos;	// No legal choices.
		}
	    }
	}

    [self moveTo:dest];
    }

@end
