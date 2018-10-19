#ifndef __ClueDefs_h
#define __ClueDefs_h
#ifdef __GNUC__
#pragma interface
#endif
//-----------------------------------------------------------------------------
// ClueDefs.h
//
//	Global declarations for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueDefs.h,v 1.1 97/05/31 10:09:53 zarnuk Exp $
// $Log:	ClueDefs.h,v $
//  Revision 1.1  97/05/31  10:09:53  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------

#import <objc/hashtable2.h>	// NXAtom
#include <cstdlib>

#ifdef __OBJC__
#import <AppKit/NSPasteboard.h>

extern NSPasteboardType const CLUE_CARD_PBTYPE;
#endif

enum ClueCategory
{
    CLUE_CATEGORY_SUSPECT,
    CLUE_CATEGORY_WEAPON,
    CLUE_CATEGORY_ROOM,
    CLUE_CATEGORY_MAX,
};


enum ClueCard
{
    CLUE_CARD_SCARLET,		// SUSPECTS
    CLUE_CARD_MUSTARD,
    CLUE_CARD_WHITE,
    CLUE_CARD_GREEN,
    CLUE_CARD_PEACOCK,
    CLUE_CARD_PLUM,
    CLUE_CARD_KNIFE,		// WEAPONS
    CLUE_CARD_CANDLESTICK,
    CLUE_CARD_REVOLVER,
    CLUE_CARD_ROPE,
    CLUE_CARD_LEAD_PIPE,
    CLUE_CARD_WRENCH,
    CLUE_CARD_HALL,			// ROOMS
    CLUE_CARD_LOUNGE,
    CLUE_CARD_DINING_ROOM,
    CLUE_CARD_KITCHEN,
    CLUE_CARD_BALL_ROOM,
    CLUE_CARD_CONSERVATORY,
    CLUE_CARD_BILLIARD_ROOM,
    CLUE_CARD_LIBRARY,
    CLUE_CARD_STUDY,
    CLUE_CARD_MAX
};

ClueCard const CLUE_SUSPECT_FIRST	= CLUE_CARD_SCARLET;
ClueCard const CLUE_SUSPECT_LAST	= CLUE_CARD_PLUM;
ClueCard const CLUE_WEAPON_FIRST	= CLUE_CARD_KNIFE;
ClueCard const CLUE_WEAPON_LAST		= CLUE_CARD_WRENCH;
ClueCard const CLUE_ROOM_FIRST		= CLUE_CARD_HALL;
ClueCard const CLUE_ROOM_LAST		= CLUE_CARD_STUDY;
ClueCard const CLUE_CARD_FIRST		= CLUE_CARD_SCARLET;
ClueCard const CLUE_CARD_LAST		= CLUE_CARD_STUDY;

int const CLUE_CATEGORY_COUNT	= (int) CLUE_CATEGORY_MAX;
int const CLUE_SUSPECT_COUNT	= CLUE_SUSPECT_LAST - CLUE_SUSPECT_FIRST + 1;
int const CLUE_WEAPON_COUNT	= CLUE_WEAPON_LAST - CLUE_WEAPON_FIRST + 1;
int const CLUE_ROOM_COUNT	= CLUE_ROOM_LAST - CLUE_ROOM_FIRST + 1;
int const CLUE_CARD_COUNT	= CLUE_CARD_LAST - CLUE_CARD_FIRST + 1;

typedef unsigned int ClueCardSet;	// Bit mask of cards.
inline ClueCardSet ClueCardToBit( ClueCard x )
	{ return ClueCardSet( 1 << x ); }
inline ClueCard ClueBitToCard( ClueCardSet x )
{
    int i = 0;
    unsigned int b = 1;
    while ((x & b) == 0)
    {
        b <<= 1;
        if (++i >= CLUE_CARD_MAX)
            break;
    }
    return ClueCard( i );
}

struct ClueCategoryRange
{
    ClueCard first;
    ClueCard last;
};

extern ClueCategoryRange const CLUE_CATEGORY_RANGE[ CLUE_CATEGORY_COUNT ];

extern ClueCard ClueCardFromName( char const* );
extern char const* ClueCardName( ClueCard );
extern ClueCategory ClueCardCategory( ClueCard x );
extern char const* ClueCategoryName( ClueCategory );


int const CLUE_NUM_PLAYERS_MIN	= 3;
int const CLUE_NUM_PLAYERS_MAX	= CLUE_SUSPECT_COUNT;

int const CLUE_NUM_CARDS_MIN = (CLUE_CARD_COUNT / CLUE_NUM_PLAYERS_MAX);
int const CLUE_NUM_CARDS_MAX =
	((CLUE_CARD_COUNT + CLUE_NUM_PLAYERS_MIN - 1) / CLUE_NUM_PLAYERS_MIN);


struct ClueSolution
{
    ClueCard  v[ CLUE_CATEGORY_COUNT ];
    ClueCard  suspect() const	{ return v[ CLUE_CATEGORY_SUSPECT ]; }
    ClueCard& suspect()		{ return v[ CLUE_CATEGORY_SUSPECT ]; }
    ClueCard  weapon() const	{ return v[ CLUE_CATEGORY_WEAPON ]; }
    ClueCard& weapon()		{ return v[ CLUE_CATEGORY_WEAPON ]; }
    ClueCard  room() const		{ return v[ CLUE_CATEGORY_ROOM ]; }
    ClueCard& room()		{ return v[ CLUE_CATEGORY_ROOM ]; }
    bool contains( ClueCard x ) const
    {
        for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
            if (v[i] == x)
                return true;
        return false;
    }
    bool operator == ( ClueSolution const& x ) const
    {
        return suspect() == x.suspect() &&
        weapon() == x.weapon() &&
        room() == x.room();
    }
};


int const CLUE_ROW_MAX	= 24;
int const CLUE_COL_MAX	= 24;

extern char const CLUE_BOARD[ CLUE_ROW_MAX ][ CLUE_COL_MAX + 1 ];

char const CLUE_CHAR_ILLEGAL		= '#';
char const CLUE_CHAR_CORRIDOR		= '.';
char const CLUE_CHAR_DOOR_UP		= '^';
char const CLUE_CHAR_DOOR_DOWN		= 'v';
char const CLUE_CHAR_DOOR_LEFT		= '<';
char const CLUE_CHAR_DOOR_RIGHT		= '>';
char const CLUE_CHAR_ROOM_HALL		= '0';
char const CLUE_CHAR_ROOM_LOUNGE	= '1';
char const CLUE_CHAR_ROOM_DINING_ROOM	= '2';
char const CLUE_CHAR_ROOM_KITCHEN	= '3';
char const CLUE_CHAR_ROOM_BALL_ROOM	= '4';
char const CLUE_CHAR_ROOM_CONSERVATORY	= '5';
char const CLUE_CHAR_ROOM_BILLIARD_ROOM	= '6';
char const CLUE_CHAR_ROOM_LIBRARY	= '7';
char const CLUE_CHAR_ROOM_STUDY		= '8';
char const CLUE_CHAR_PASSAGE_LOUNGE	= 'B';
char const CLUE_CHAR_PASSAGE_KITCHEN	= 'D';
char const CLUE_CHAR_PASSAGE_CONSERVATORY = 'F';
char const CLUE_CHAR_PASSAGE_STUDY	= 'I';
char const CLUE_CHAR_START_SCARLET	= 'a';
char const CLUE_CHAR_START_MUSTARD	= 'b';
char const CLUE_CHAR_START_WHITE	= 'c';
char const CLUE_CHAR_START_GREEN	= 'd';
char const CLUE_CHAR_START_PEACOCK	= 'e';
char const CLUE_CHAR_START_PLUM		= 'f';

char const CLUE_CHAR_START_FIRST	= CLUE_CHAR_START_SCARLET;
char const CLUE_CHAR_START_LAST		= CLUE_CHAR_START_PLUM;
char const CLUE_CHAR_ROOM_FIRST		= CLUE_CHAR_ROOM_HALL;
char const CLUE_CHAR_ROOM_LAST		= CLUE_CHAR_ROOM_STUDY;

inline bool ClueStartChar( char ch )
{ return CLUE_CHAR_START_FIRST <= ch && ch <= CLUE_CHAR_START_LAST; }

inline bool ClueIllegalChar( char ch )
{ return ch == CLUE_CHAR_ILLEGAL || ClueStartChar( ch ); }

inline bool ClueRoomChar( char ch )
{ return CLUE_CHAR_ROOM_FIRST <= ch && ch <= CLUE_CHAR_ROOM_LAST; }

inline bool CluePassageChar( char ch )
{ return ch == CLUE_CHAR_PASSAGE_LOUNGE ||
    ch == CLUE_CHAR_PASSAGE_KITCHEN ||
    ch == CLUE_CHAR_PASSAGE_CONSERVATORY ||
    ch == CLUE_CHAR_PASSAGE_STUDY; }

inline bool ClueDoorChar( char ch )
{ return ch == CLUE_CHAR_DOOR_UP || ch == CLUE_CHAR_DOOR_DOWN ||
    ch == CLUE_CHAR_DOOR_UP || ch == CLUE_CHAR_DOOR_DOWN; }

inline bool ClueCorridorChar( char ch )
{ return ch == CLUE_CHAR_CORRIDOR || ClueDoorChar( ch ); }




struct ClueCoord
{
    int row;
    int col;
};

inline bool ClueGoodCoord( ClueCoord const& x )
{ return 0 <= x.row && x.row < CLUE_ROW_MAX &&
    0 <= x.col && x.col < CLUE_COL_MAX; }

inline bool operator == ( ClueCoord const& a, ClueCoord const& b )
{ return a.row == b.row && a.col == b.col; }

inline bool operator != ( ClueCoord const& a, ClueCoord const& b )
{ return a.row != b.row || a.col != b.col; }


extern ClueCoord const CLUE_START_POS[ CLUE_SUSPECT_COUNT ];

struct ClueDoor
{
    ClueCoord pos;
    ClueCard  room;
};

int const CLUE_DOOR_COUNT = 17;
extern ClueDoor const CLUE_DOOR[ CLUE_DOOR_COUNT ];

extern ClueCard const CLUE_PASSAGE[ CLUE_ROOM_COUNT ];
inline ClueCard CluePassage( ClueCard room )
{
    if (CLUE_ROOM_FIRST <= room && room <= CLUE_ROOM_LAST)
        return CLUE_PASSAGE[ room - CLUE_ROOM_FIRST ];
    return CLUE_CARD_MAX;
}

ClueCard ClueRoomAt( ClueCoord );	// Room, or CLUE_CARD_MAX.
ClueCard ClueDoorAt( ClueCoord );	// Room, or CLUE_CARD_MAX.
bool ClueCorridorAt( ClueCoord );	// Corridor cells, (doors included).
bool ClueIllegalAt( ClueCoord );	// Illegal cells.

struct ClueBox				// Bounding boxes for rooms.
{				// Cell coords are inclusive limits.
    int	top;
    int	left;
    int	bottom;
    int	right;
};

extern ClueBox const CLUE_ROOM_BOX[ CLUE_ROOM_COUNT ];
extern ClueCoord ClueRoomCoord( ClueCard room );	// Randomly chosen.


// Minimum distances between rooms via corridors (no diagnonal movement).
extern int const CLUE_DISTANCE[ CLUE_ROOM_COUNT ][ CLUE_ROOM_COUNT ];


#define	RANDOM()	random()
#define	SRANDOM(N)	srandom(N)

//-----------------------------------------------------------------------------
// random_int
//	Return a random integer, x, from the range: 0 <= x < N.
//-----------------------------------------------------------------------------
inline static unsigned int random_int( unsigned int N )
{
    return (N <= 1 ? 0 : (unsigned int) RANDOM() % N);
}


#endif // __ClueDefs_h
