#ifndef __ClueMap_h
#define __ClueMap_h
#ifdef __GNUC__
#pragma interface
#endif
//-----------------------------------------------------------------------------
// ClueMap.h
//
//	Route planning and distance calculations on the board.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#ifndef __ClueDefs_h
#include "ClueDefs.h"
#endif

class ClueCoordArray;


class ClueMap
	{
private:
	int map[ CLUE_ROW_MAX ][ CLUE_COL_MAX ];

	void add_rooms( int const reachable[] );
	void do_calc( int cooked[ CLUE_ROW_MAX ][ CLUE_COL_MAX ],
			int reachable_rooms[],
			int die_roll, ClueCoord start_pos );
	void init_distance_map( ClueCoordArray const& obstacles );
	void do_calc_distance( ClueCoord start_pos );
	void fix_distances( int rooms[], ClueCoord start_pos );
public:
	bool calcLegal( int die_roll,		// false = no legal squares.
			ClueCoord start_pos,	// true = one or more legal.
			ClueCoordArray const& obstacles );
	void allSquaresInRoom( ClueCard room,
				ClueCoordArray const& obstacles );
	bool isLegal( ClueCoord pos ) const
		{ return map[ pos.row ][ pos.col ] != 0; }


	void calcDistance( int rooms[],
			ClueCoord start_pos,
			ClueCoordArray const& obstacles );
	int distanceAt( ClueCoord pos ) const
		{ return map[ pos.row ][ pos.col ]; }
	};

#endif // __ClueMap_h
