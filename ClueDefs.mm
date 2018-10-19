//-----------------------------------------------------------------------------
// ClueDefs.cc
//
//	Global declarations for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueDefs.cc,v 1.1 97/05/31 10:09:56 zarnuk Exp $
// $Log:	ClueDefs.cc,v $
//  Revision 1.1  97/05/31  10:09:56  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#ifdef __GNUC__
#pragma implementation
#endif
#include "ClueDefs.h"

extern "C" {
#include <assert.h>
#include <string.h>
}


NSPasteboardType const CLUE_CARD_PBTYPE = @"com.github.MaddTheSane.NeXTClue.ClueCard";


ClueCategoryRange const CLUE_CATEGORY_RANGE[ CLUE_CATEGORY_COUNT ] =
	{
	{ CLUE_SUSPECT_FIRST, CLUE_SUSPECT_LAST },
	{ CLUE_WEAPON_FIRST, CLUE_WEAPON_LAST },
	{ CLUE_ROOM_FIRST, CLUE_ROOM_LAST },
	};


char const CLUE_BOARD[ CLUE_ROW_MAX ][ CLUE_COL_MAX + 1 ] =
	{
//	           1         2     
//	 012345678901234567890123
	"I33333#...c44d....55555B",	// 0
	"333333..44444444..555555",	// 1
	"333333..44444444..555555",	// 2
	"333333..44444444..555555",	// 3
	"333333.>44444444<.>5555#",	// 4
	"333333..44444444.......e",	// 5
	"....^...44444444.......#",	// 6
	"#........^....^...666666",	// 7
	"22222............>666666",	// 8
	"22222222..#####...666666",	// 9
	"22222222..#####...666666",	// 0 1
	"22222222<.#####...666666",	// 1
	"22222222..#####.....v.^#",	// 2
	"22222222..#####...77777#",	// 3
	"22222222..#####..7777777",	// 4
	"#.....^...#####.>7777777",	// 5
	"b..........vv....7777777",	// 6
	"#.....v..000000...77777#",	// 7
	"1111111..000000........f",	// 8
	"1111111..000000<.v.....#",	// 9
	"1111111..000000..8888888",	// 0 2
	"1111111..000000..8888888",	// 1
	"1111111..000000..8888888",	// 2
	"F11111#a#000000#.888888D",	// 3
//	 012345678901234567890123
//	           1         2     
	};


ClueCoord const CLUE_START_POS[ CLUE_SUSPECT_COUNT ] =
	{
	{ 23,  7 },	// CLUE_CARD_SCARLET	(a)
	{ 16,  0 },	// CLUE_CARD_MUSTARD	(b)
	{  0, 10 },	// CLUE_CARD_WHITE	(c)
	{  0, 13 },	// CLUE_CARD_GREEN	(d)
	{  5, 23 },	// CLUE_CARD_PEACOCK	(e)
	{ 18, 23 },	// CLUE_CARD_PLUM	(f)
	};



ClueDoor const CLUE_DOOR[ CLUE_DOOR_COUNT ] =
	{
	{ {  4,  7 }, CLUE_CARD_BALL_ROOM },
	{ {  4, 16 }, CLUE_CARD_BALL_ROOM },
	{ {  4, 18 }, CLUE_CARD_CONSERVATORY },
	{ {  6,  4 }, CLUE_CARD_KITCHEN },
	{ {  7,  9 }, CLUE_CARD_BALL_ROOM },
	{ {  7, 14 }, CLUE_CARD_BALL_ROOM },
	{ {  8, 17 }, CLUE_CARD_BILLIARD_ROOM },
	{ { 11,  8 }, CLUE_CARD_DINING_ROOM },
	{ { 12, 20 }, CLUE_CARD_LIBRARY },
	{ { 12, 22 }, CLUE_CARD_BILLIARD_ROOM },
	{ { 15,  6 }, CLUE_CARD_DINING_ROOM },
	{ { 15, 16 }, CLUE_CARD_LIBRARY },
	{ { 16, 11 }, CLUE_CARD_HALL },
	{ { 16, 12 }, CLUE_CARD_HALL },
	{ { 17,  6 }, CLUE_CARD_LOUNGE },
	{ { 19, 15 }, CLUE_CARD_HALL },
	{ { 19, 17 }, CLUE_CARD_STUDY },
	};


ClueCard const CLUE_PASSAGE[ CLUE_ROOM_COUNT ] =
	{
	CLUE_CARD_MAX,		// CLUE_CARD_HALL
	CLUE_CARD_CONSERVATORY,	// CLUE_CARD_LOUNGE
	CLUE_CARD_MAX,		// CLUE_CARD_DINING_ROOM
	CLUE_CARD_STUDY,	// CLUE_CARD_KITCHEN
	CLUE_CARD_MAX,		// CLUE_CARD_BALL_ROOM
	CLUE_CARD_LOUNGE,	// CLUE_CARD_CONSERVATORY
	CLUE_CARD_MAX,		// CLUE_CARD_BILLIARD_ROOM
	CLUE_CARD_MAX,		// CLUE_CARD_LIBRARY
	CLUE_CARD_KITCHEN,	// CLUE_CARD_STUDY
	};


ClueBox const CLUE_ROOM_BOX[ CLUE_ROOM_COUNT ] =
	{
	{ 17,  9, 23, 14 },	// CLUE_CARD_HALL
	{ 18,  0, 23,  6 },	// CLUE_CARD_LOUNGE
	{  8,  0, 14,  7 },	// CLUE_CARD_DINING_ROOM
	{  0,  0,  5,  5 },	// CLUE_CARD_KITCHEN
	{  0,  8,  6, 15 },	// CLUE_CARD_BALL_ROOM
	{  0, 18,  4, 23 },	// CLUE_CARD_CONSERVATORY
	{  7, 18, 11, 23 },	// CLUE_CARD_BILLIARD_ROOM
	{ 13, 17, 17, 23 },	// CLUE_CARD_LIBRARY
	{ 20, 17, 23, 23 },	// CLUE_CARD_STUDY
	};

// Minimum distances between rooms via corridors (no diagnonal movement).
extern int const CLUE_DISTANCE[ CLUE_ROOM_COUNT ][ CLUE_ROOM_COUNT ] =
	{
	// A   B   C   D   E   F   G   H   I
	{  0,  8,  8, 19, 13, 20, 15,  7,  4 },	// A HALL
	{  8,  0,  4, 19, 15, 27, 22, 14, 17 },	// B LOUNGE
	{  8,  4,  0, 11,  7, 19, 14, 14, 17 },	// C DINING_ROOM
	{ 19, 19, 11,  0,  7, 20, 17, 23, 28 },	// D KITCHEN
	{ 13, 15,  7,  7,  0,  4,  6, 12, 17 },	// E BALL_ROOM
	{ 20, 27, 19, 20,  4,  0,  7, 14, 20 },	// F CONSERVATORY
	{ 15, 22, 14, 17,  6,  7,  0,  4, 15 },	// G BILLIARD_ROOM
	{  7, 14, 14, 23, 12, 14,  4,  0,  7 },	// H LIBRARY
	{  4, 17, 17, 28, 17, 20, 15,  7,  0 },	// I STUDY
	// A   B   C   D   E   F   G   H   I
	};


//-----------------------------------------------------------------------------
// ClueRoomCoord
//-----------------------------------------------------------------------------
ClueCoord ClueRoomCoord( ClueCard room )
{
    assert( CLUE_ROOM_FIRST <= room && room <= CLUE_ROOM_LAST );
    unsigned int const n = room - CLUE_ROOM_FIRST;

    char const room_char = CLUE_CHAR_ROOM_FIRST + n;
    ClueBox const box = CLUE_ROOM_BOX[ n ];

    int const nrows = box.bottom - box.top + 1;
    int const ncols = box.right - box.left + 1;
    int const lim = nrows * ncols;

    int r,c;
    do  {
        int const x = random_int( lim );
        c = box.left + x % ncols;
        r = box.top + x / ncols;
    }
    while (CLUE_BOARD[r][c] != room_char);

    ClueCoord coord = { r, c };
    return coord;
}


//-----------------------------------------------------------------------------
// ClueRoomAt
//-----------------------------------------------------------------------------
ClueCard ClueRoomAt( ClueCoord pos )
{
    if (ClueGoodCoord( pos ))
    {
        char const c = CLUE_BOARD[ pos.row ][ pos.col ];
        if ('0' <= c && c <= '8')	// What about secret passage corners?
            return ClueCard( CLUE_ROOM_FIRST - '0' + c );
    }
    return CLUE_CARD_MAX;
}


//-----------------------------------------------------------------------------
// ClueDoorAt
//-----------------------------------------------------------------------------
ClueCard ClueDoorAt( ClueCoord pos )
{
    for (int i = 0; i < CLUE_DOOR_COUNT; i++)
        if (CLUE_DOOR[i].pos == pos)
            return CLUE_DOOR[i].room;
    return CLUE_CARD_MAX;
}


//-----------------------------------------------------------------------------
// ClueCorridorAt
//-----------------------------------------------------------------------------
bool ClueCorridorAt( ClueCoord pos )
{
    return ClueGoodCoord( pos ) &&
    ClueCorridorChar( CLUE_BOARD[ pos.row ][ pos.col ] );
}


//-----------------------------------------------------------------------------
// ClueIllegalAt
//-----------------------------------------------------------------------------
bool ClueIllegalAt( ClueCoord pos )
{
    return !ClueGoodCoord( pos ) ||
    ClueIllegalChar( CLUE_BOARD[ pos.row ][ pos.col ] );
}


//-----------------------------------------------------------------------------
// NAMES
//-----------------------------------------------------------------------------
static char const* const CLUE_NAMES[ CLUE_CARD_MAX + 1 ] =
{
    "scarlet",
    "mustard",
    "white",
    "green",
    "peacock",
    "plum",
    "knife",
    "candlestick",
    "revolver",
    "rope",
    "lead-pipe",
    "wrench",
    "hall",
    "lounge",
    "dining-room",
    "kitchen",
    "ball-room",
    "conservatory",
    "billiard-room",
    "library",
    "study",
    "error"
};


static char const* const CLUE_CATEGORY[ CLUE_CATEGORY_MAX + 1 ] =
{
    "suspect",
    "weapon",
    "room",
    "error"
};


//-----------------------------------------------------------------------------
// ClueCardName
//-----------------------------------------------------------------------------
char const* ClueCardName( ClueCard x )
{
    return CLUE_NAMES[ x < CLUE_CARD_MAX ? x : CLUE_CARD_MAX ];
}


//-----------------------------------------------------------------------------
// ClueCardFromName
//-----------------------------------------------------------------------------
ClueCard ClueCardFromName( char const* name )
{
    unsigned int i;
    for (i = 0; i < (unsigned int) CLUE_CARD_MAX; i++)
        if (strcmp( CLUE_NAMES[i], name ) == 0)
            return ClueCard(i);
    return CLUE_CARD_MAX;
}


//-----------------------------------------------------------------------------
// ClueCategoryName
//-----------------------------------------------------------------------------
char const* ClueCategoryName( ClueCategory x )
{
    return CLUE_CATEGORY[ x < CLUE_CATEGORY_MAX ? x : CLUE_CATEGORY_MAX ];
}


//-----------------------------------------------------------------------------
// ClueCardCategory
//-----------------------------------------------------------------------------
ClueCategory ClueCardCategory( ClueCard x )
{
    ClueCategory rc = CLUE_CATEGORY_MAX;

    if (x <= CLUE_SUSPECT_LAST)		rc = CLUE_CATEGORY_SUSPECT;
    else if (x <= CLUE_WEAPON_LAST)	rc = CLUE_CATEGORY_WEAPON;
    else if (x <= CLUE_ROOM_LAST)	rc = CLUE_CATEGORY_ROOM;

    return rc;
}
