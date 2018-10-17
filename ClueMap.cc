//-----------------------------------------------------------------------------
// ClueMap.cc
//
//	Route planning and distance calculations on the board.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueMap.cc,v 1.1 97/05/31 10:11:13 zarnuk Exp $
// $Log:	ClueMap.cc,v $
//  Revision 1.1  97/05/31  10:11:13  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#ifdef __GNUC__
#pragma implementation
#endif
#include "ClueMap.h"
#include "ClueCoordArray.h"

extern "C" {
#include <limits.h>	// INT_MAX
#include <string.h>	// memset()
}


int const CLUE_PATH_MAX = 12;			// Two dice.

int const CORRIDOR_CELL = CLUE_CARD_MAX + 1;

static ClueCoord const DELTAS[] =
	{ { -1, 0 }, { 0, -1 }, { 1, 0 }, { 0, 1 } };
int const NUM_DELTAS = sizeof(DELTAS) / sizeof(DELTAS[0]);
static ClueCoord const* const DELTA_LIM = DELTAS + NUM_DELTAS;



//-----------------------------------------------------------------------------
// cook_map
//	Create a pre-cooked version of the map to speed up testing whether
//	or not the player can pass through the indicated cell.  Invalid
//	cells are set to zero.  Valid cells are given non-zero values.
//	Door cells are given the id of the room + 1, corridor cells are
//	given CLUE_CARD_MAX + 1.
//-----------------------------------------------------------------------------
static void cook_map( int cooked[ CLUE_ROW_MAX ][ CLUE_COL_MAX ],
			ClueCoordArray const& obstacles )
    {
    for (int r = 0; r < CLUE_ROW_MAX; r++)
	for (int c = 0; c < CLUE_COL_MAX; c++)
	    if (CLUE_BOARD[r][c] == CLUE_CHAR_CORRIDOR)
		cooked[r][c] = CORRIDOR_CELL;
	    else
		cooked[r][c] = 0;

    for (int j = 0; j < CLUE_DOOR_COUNT; j++)
	{
	ClueDoor const& door = CLUE_DOOR[j];
	cooked[ door.pos.row ][ door.pos.col ] = (door.room + 1);
	}

    int const n = obstacles.count();
    for (int i = 0; i < n; i++)
	{
	ClueCoord const& pos = obstacles[i];
	cooked[ pos.row ][ pos.col ] = 0;
	}
    }


//-----------------------------------------------------------------------------
// add_rooms
//	Some of these rooms are reachable from the given die-roll.  Mark
//	their cells legal.
//-----------------------------------------------------------------------------
void ClueMap::add_rooms( int const reachable[] )
    {
    bool have_one = false;
    for (int i = 0; i < CLUE_ROOM_COUNT; i++)
	if (reachable[i] != 0)
	    { have_one = true; break; }

    if (have_one)
	for (int r = 0; r < CLUE_ROW_MAX; r++)
	    for (int c = 0; c < CLUE_COL_MAX; c++)
		{
		char const ch = CLUE_BOARD[r][c];
		if (ClueRoomChar(ch) && 
		    reachable[ ch - CLUE_CHAR_ROOM_FIRST ] != 0)
		    map[r][c] = 1;
		}
    }


//-----------------------------------------------------------------------------
// do_calc
//	Assign non-zero values to all map[][] cells that are reachable from
//	the given start_pos with the given die_roll.
//-----------------------------------------------------------------------------
void ClueMap::do_calc( int cooked[ CLUE_ROW_MAX ][ CLUE_COL_MAX ],
			int reachable_rooms[],
			int die_roll, ClueCoord start_pos )
    {
    ClueCoord path_stack[ CLUE_PATH_MAX ];
    ClueCoord const* deltas_stack[ CLUE_PATH_MAX ];

    int n = die_roll;			// Length of rest of path.
    ClueCoord* path = path_stack;
    ClueCoord const** deltas = deltas_stack;

    n--;
    *(path++) = start_pos;
    *(deltas++) = DELTA_LIM;
    int const x = cooked[ start_pos.row ][ start_pos.col ];
    cooked[ start_pos.row ][ start_pos.col ] = ~x;

    while (path > path_stack)
	{
	ClueCoord pos = *--path;		// stack pop.
	ClueCoord const* delta = *--deltas;
	int const x = ~(cooked[ pos.row ][ pos.col ]);
	cooked[ pos.row ][ pos.col ] = x;

	if (n++ == 0)				// Used full die-roll.
	    {
	    map[ pos.row ][ pos.col ] = 1;
	    }
	else
	    {
	    if (x != CORRIDOR_CELL)
		reachable_rooms[ (x - 1 - CLUE_ROOM_FIRST) ] = 1;

	    while (delta > DELTAS)		// Next direction from pos...
		{
		delta--;
    
		ClueCoord next_pos;
		next_pos.row = pos.row + delta->row;
		next_pos.col = pos.col + delta->col;
		if (ClueGoodCoord( next_pos ))
		    {
		    int const y = cooked[ next_pos.row ][ next_pos.col ];
		    if (y > 0)			// Clear cell...
			{
			n--;
			*(path++) = pos;	// Push pos back on stack.
			*(deltas++) = delta;
			cooked[ pos.row ][ pos.col ] = ~x;
			n--;
			*(path++) = next_pos;	// Push next pos onto stack.
			*(deltas++) = DELTA_LIM;
			cooked[ next_pos.row ][ next_pos.col ] = ~y;
			break;			// break out of inner loop.
			}
		    }
		}
	    }
	}
    }



//-----------------------------------------------------------------------------
// calcLegal
//-----------------------------------------------------------------------------
bool ClueMap::calcLegal( int die_roll,
			ClueCoord start_pos,
			ClueCoordArray const& obstacles )
    {
    memset( map, 0, sizeof(map) );	// Initially, no spot is legal.

    int reachable_rooms[ CLUE_ROOM_COUNT ];
    memset( reachable_rooms, 0, sizeof(reachable_rooms) );

    int cooked[ CLUE_ROW_MAX ][ CLUE_COL_MAX ];
    cook_map( cooked, obstacles );

    ClueCard const room = ClueRoomAt( start_pos );
    if (room == CLUE_CARD_MAX)		// Not in a room.
	{				// First cell is not on path.
	do_calc( cooked, reachable_rooms, die_roll + 1, start_pos );
	}
    else				// In a room.
	{
	for (int i = 0; i < CLUE_DOOR_COUNT; i++)
	    {
	    ClueDoor const door = CLUE_DOOR[i];
	    if (door.room == room &&
		cooked[ door.pos.row ][ door.pos.col ] > 0)
		{
		if (die_roll == 1)
		    map[ door.pos.row ][ door.pos.col ] = 1;
		else
		    do_calc( cooked, reachable_rooms, die_roll, door.pos );
		}
	    }
	reachable_rooms[ room - CLUE_ROOM_FIRST ] = 0;
	}

    add_rooms( reachable_rooms );

    for (int r = 0; r < CLUE_ROW_MAX; r++)
	for (int c = 0; c < CLUE_COL_MAX; c++)
	    if (map[r][c] != 0)
		return true;

    return false;
    }



//-----------------------------------------------------------------------------
// allSquaresInRoom
//-----------------------------------------------------------------------------
void ClueMap::allSquaresInRoom( ClueCard room,
				ClueCoordArray const& obstacles )
    {
    memset( map, 0, sizeof(map) );	// Initially, no spot is legal.

    int reachable_rooms[ CLUE_ROOM_COUNT ];
    memset( reachable_rooms, 0, sizeof(reachable_rooms) );

    reachable_rooms[ room - CLUE_ROOM_FIRST ] = 1;

    add_rooms( reachable_rooms );

    int const n = obstacles.count();
    for (int i = 0; i < n; i++)
	{
	ClueCoord const& pos = obstacles[i];
	map[ pos.row ][ pos.col ] = 0;
	}
    }


//-----------------------------------------------------------------------------
// init_distance_map
//-----------------------------------------------------------------------------
void ClueMap::init_distance_map( ClueCoordArray const& obstacles )
    {
    for (int r = 0; r < CLUE_ROW_MAX; r++)
	for (int c = 0; c < CLUE_COL_MAX; c++)
	    {
	    char const ch = CLUE_BOARD[r][c];
	    if (ClueCorridorChar( ch ))
		map[r][c] = 0;
	    else
		map[r][c] = INT_MAX;
	    }

    int const n = obstacles.count();
    for (int i = 0; i < n; i++)
	{
	ClueCoord const& pos = obstacles[i];
	map[ pos.row ][ pos.col ] = INT_MAX;
	}
    }


//-----------------------------------------------------------------------------
// do_calc_distance
//-----------------------------------------------------------------------------
void ClueMap::do_calc_distance( ClueCoord start_pos )
    {
    ClueCoordArray x;
    ClueCoordArray y;
    ClueCoordArray* curr = &x;
    ClueCoordArray* next = &y;
    int distance = 0;

    ClueCard const room = ClueRoomAt( start_pos );
    if (room == CLUE_CARD_MAX)	// Not in a room
	{
	map[ start_pos.row ][ start_pos.col ] = distance;
	next->push( start_pos );
	}
    else
	{
	distance++;
	for (int i = 0; i < CLUE_DOOR_COUNT; i++)
	    if (CLUE_DOOR[i].room == room)
		{
		ClueCoord const pos = CLUE_DOOR[i].pos;
		map[ pos.row ][ pos.col ] = distance;
		next->push( pos );
		}
	}

    do  {
	distance++;
	ClueCoordArray* temp = curr;
	curr = next;
	next = temp;
	next->empty();

	while (curr->count() > 0)
	    {
	    ClueCoord pos = curr->pop();
	    for (ClueCoord const* d = DELTAS; d < DELTA_LIM; d++)
		{
		ClueCoord next_pos;
		next_pos.row = pos.row + d->row;
		next_pos.col = pos.col + d->col;
		if (ClueGoodCoord( next_pos ) &&
		    map[ next_pos.row ][ next_pos.col ] == 0)
		    {
		    map[ next_pos.row ][ next_pos.col ] = distance;
		    next->push( next_pos );
		    }
		}
	    }
	}
    while (next->count() > 0);

    if (room == CLUE_CARD_MAX)
	map[ start_pos.row ][ start_pos.col ] = 0;
    }


//-----------------------------------------------------------------------------
// fix_distances
//-----------------------------------------------------------------------------
void ClueMap::fix_distances( int rooms[], ClueCoord start_pos )
    {
    for (int i = 0; i < CLUE_ROOM_COUNT; i++)
	rooms[i] = INT_MAX;

    ClueCard const start_room = ClueRoomAt( start_pos );
    if (start_room != CLUE_CARD_MAX)
	rooms[ start_room - CLUE_ROOM_FIRST ] = 0;

    for (int j = 0; j < CLUE_DOOR_COUNT; j++)
	{
	int const r = CLUE_DOOR[j].room - CLUE_ROOM_FIRST;
	ClueCoord const door = CLUE_DOOR[j].pos;
	int const distance = map[ door.row ][ door.col ];
	if (rooms[r] > distance)
	    rooms[r] = distance;
	}

    for (int r = 0; r < CLUE_ROW_MAX; r++)
	for (int c = 0; c < CLUE_COL_MAX; c++)
	    {
	    char const ch = CLUE_BOARD[r][c];
	    if (ClueRoomChar( ch ))
		map[r][c] = rooms[ ch - CLUE_CHAR_ROOM_FIRST ];
	    else if (map[r][c] == 0)
		map[r][c] = INT_MAX;
	    }

    if (start_room == CLUE_CARD_MAX)
	map[ start_pos.row ][ start_pos.col ] = 0;
    }


//-----------------------------------------------------------------------------
// calcDistance
//-----------------------------------------------------------------------------
void ClueMap::calcDistance( int rooms[], ClueCoord start_pos,
				ClueCoordArray const& obstacles )
    {
    init_distance_map( obstacles );
    do_calc_distance( start_pos );
    fix_distances( rooms, start_pos );
    }

