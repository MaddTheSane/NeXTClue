//-----------------------------------------------------------------------------
// ClueCondArray.cc
//
//	List of conditional deductions exposed during play for use by the
//	ClueDeeDucer computer player.
//
// NOTES:
//	* minCardsForPlayer() can be upgraded to determine if there is a
//	unique solution -- in which case the conditionals can be converted
//	into definite HOLDS / NOT_HOLDS settings.
//
//	* I discovered another deduction rule that can be added:  If two
//	players, p1 and p2 both have the same two-card conditional c1, c2
//	(ex: scarlet, knife), then no other players can be holding c1 and
//	c2, and c1 and c2 cannot be in the solution.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueCondArray.cc,v 1.1 97/05/31 10:08:29 zarnuk Exp Locker: zarnuk $
// $Log:	ClueCondArray.cc,v $
//  Revision 1.1  97/05/31  10:08:29  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#ifdef __GNUC__
#pragma implementation
#endif
#include "ClueCondArray.h"
#include "ClueUpdateStack.h"

extern "C" {
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>	// malloc(), realloc(), free()
#include <string.h>	// memmove(), memset()
}



//-----------------------------------------------------------------------------
// diff
//	Determine the number of cards in 'x' that are not in 'y', and
//	the number of cards in 'y' that are not in 'x'.
//-----------------------------------------------------------------------------
inline void diff( int& nx, int& ny,
		ClueSolution const& x,
		ClueSolution const& y )
    {
    int tnx = 0;
    int tny = 0;
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	{
	ClueCard const cx = x.v[i];
	ClueCard const cy = y.v[i];
	if (cx != cy)
	    {
	    if (cx != CLUE_CARD_MAX) tnx++;
	    if (cy != CLUE_CARD_MAX) tny++;
	    }
	}
    nx = tnx;
    ny = tny;
    }


//-----------------------------------------------------------------------------
// subset
//	Is 'x' a subset of 'y'?
//-----------------------------------------------------------------------------
inline bool subset( ClueSolution const& x, ClueSolution const& y )
    {
    int nx;
    int ny;
    diff( nx, ny, x, y );
    return nx == 0;
    }


//-----------------------------------------------------------------------------
// superset
//	Is 'x' a proper superset of 'y'?
//-----------------------------------------------------------------------------
inline bool superset( ClueSolution const& x, ClueSolution const& y )
    {
    int nx;
    int ny;
    diff( nx, ny, x, y );
    return nx > 0 && ny == 0;
    }


//-----------------------------------------------------------------------------
// singleton
//-----------------------------------------------------------------------------
inline bool singleton( ClueCard& x, ClueSolution const& s )
    {
    ClueCard c = CLUE_CARD_MAX;
    int n = 0;
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	if (s.v[i] != CLUE_CARD_MAX)
	    {
	    c = s.v[i];
	    n++;
	    }
    x = c;
    return (n == 1);
    }


//-----------------------------------------------------------------------------
// remove
//-----------------------------------------------------------------------------
inline void remove( ClueCard x, ClueSolution& s )
    {
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	if (s.v[i] == x)
	    s.v[i] = CLUE_CARD_MAX;
    }




//-----------------------------------------------------------------------------
// Constructor / Destructor
//-----------------------------------------------------------------------------
ClueCondArray::ClueCondArray():num_recs(0),max_recs(8)
    { recs = (CondRec*) malloc( max_recs * sizeof(*recs) ); }

ClueCondArray::~ClueCondArray()		{ free( recs ); }


//-----------------------------------------------------------------------------
// expand
//-----------------------------------------------------------------------------
void ClueCondArray::expand()
    {
    max_recs += max_recs;
    recs = (CondRec*) realloc( recs, max_recs * sizeof(*recs) );
    }


//-----------------------------------------------------------------------------
// append
//-----------------------------------------------------------------------------
void ClueCondArray::append( CondRec const& r )
    {
    if (num_recs >= max_recs) expand();
    recs[ num_recs++ ] = r;
    }


void ClueCondArray::append( int p, ClueSolution const& s )
    {
    CondRec const x = { p, s };
    append( x );
    }


//-----------------------------------------------------------------------------
// deleteAt
//-----------------------------------------------------------------------------
void ClueCondArray::deleteAt( int n )
    {
    if (n < --num_recs)
	{
	CondRec* const p = recs + n;
	memmove( p, p + 1, (num_recs - n) * sizeof(*p) );
	}
    }


//-----------------------------------------------------------------------------
// removeSupersets
//-----------------------------------------------------------------------------
void ClueCondArray::removeSupersets( int p, ClueSolution const& s )
    {
    for (int i = num_recs; i-- > 0;)
	{
	CondRec const& r = recs[i];
	if (r.p == p && superset( r.s, s ))
	    deleteAt( i );
	}
    }


//-----------------------------------------------------------------------------
// findSubset
//-----------------------------------------------------------------------------
bool ClueCondArray::findSubset( int p, ClueSolution const& s ) const
    {
    for (int i = num_recs; i-- > 0;)
	{
	CondRec const& r = recs[i];
	if (r.p == p && subset( r.s, s ))
	    return true;
	}
    return false;
    }


//-----------------------------------------------------------------------------
// add
//-----------------------------------------------------------------------------
void ClueCondArray::add( int p, ClueSolution const& s )
    {
    removeSupersets( p, s );
    if (!findSubset( p, s ))
	append( p, s );
    }


//-----------------------------------------------------------------------------
// holds
//-----------------------------------------------------------------------------
void ClueCondArray::holds( int p, ClueCard c )
    {
    for (int i = num_recs; i-- > 0;)
	{
	CondRec& r = recs[i];
	if (r.p == p && r.s.contains(c))
	    deleteAt( i );
	}
    }


//-----------------------------------------------------------------------------
// not_holds
//-----------------------------------------------------------------------------
void ClueCondArray::not_holds( ClueUpdateStack& stack, int p, ClueCard c )
    {
    for (int i = num_recs; i-- > 0;)
	{
	CondRec& r = recs[i];
	if (r.p == p && r.s.contains(c))
	    {
	    remove( c, r.s );
	    ClueCard x;
	    if (singleton( x, r.s ))
		stack.push( p, true, x );
	    }
	}
    }


//-----------------------------------------------------------------------------
// countContains
//-----------------------------------------------------------------------------
int ClueCondArray::countContains( ClueCard c ) const
    {
    int n = 0;
    for (int i = 0; i < num_recs; i++)
	if (recs[i].s.contains(c))
	    n++;
    return n;
    }


//-----------------------------------------------------------------------------
// countForPlayer
//	Count the number of conditionals for this player.
//-----------------------------------------------------------------------------
int ClueCondArray::countForPlayer( int p ) const
    {
    int n = 0;
    for (int i = 0; i < num_recs; i++)
	if (recs[i].p == p)
	    n++;
    return n;
    }


//-----------------------------------------------------------------------------
// cardsForCond
//	Return a bit-mask of all cards in this conditional solution.
//-----------------------------------------------------------------------------
ClueCardSet ClueCondArray::cardsForCond( ClueSolution const& s )
    {
    ClueCardSet m = 0;
    for (int j = 0; j < CLUE_CATEGORY_COUNT; j++)
	{
	ClueCard const x = s.v[j];
	if (x != CLUE_CARD_MAX)
	    m |= (1 << x);
	}
    return m;
    }


//-----------------------------------------------------------------------------
// cardsForPlayer
//	Return a bit-mask of all cards included in all conditionals for
//	this player.
//-----------------------------------------------------------------------------
ClueCardSet ClueCondArray::cardsForPlayer( int p ) const
    {
    ClueCardSet m = 0;
    for (int i = 0; i < num_recs; i++)
	if (recs[i].p == p)
	    m |= cardsForCond( recs[i].s );
    return m;
    }


//-----------------------------------------------------------------------------
// min_cards
//-----------------------------------------------------------------------------
void ClueCondArray::min_cards( int i ) const
    {
    if (i >= num_recs)
	{
	if (min_len > curr_len)
	    min_len = curr_len;
	}
    else if (recs[i].p != curr_player ||
	    (curr_set & cardsForCond( recs[i].s )) != 0)
	min_cards( i + 1 );
    else
	{
	for (int j = 0; j < CLUE_CATEGORY_COUNT; j++)
	    {
	    ClueCard const x = recs[i].s.v[j];
	    if (x != CLUE_CARD_MAX)
		{
		unsigned int const b = (1 << x);
		curr_set |= b;
		curr_len++;
		min_cards( i + 1 );
		curr_len--;
		curr_set &= ~b;
		}
	    }
	}
    }


//-----------------------------------------------------------------------------
// minCardsForPlayer
//	Calculate the minimum number of cards needed to satisfy all of the
//	conditionals for this player.
//-----------------------------------------------------------------------------
int ClueCondArray::minCardsForPlayer( int player ) const
    {
    curr_set = 0;
    curr_player = player;
    curr_len = 0;
    min_len = CLUE_CARD_COUNT;

    min_cards( 0 );

    if (min_len == CLUE_CARD_COUNT)
	min_len = 0;

    return min_len;
    }


//-----------------------------------------------------------------------------
// dump
//-----------------------------------------------------------------------------
void ClueCondArray::dump() const
    {
    FILE* output = stdout;
    if (num_recs == 0)
	fprintf( output, "No conditions...\n" );
    else
	{
	fprintf( output, "Player: holds one of cards...\n" );
	for (int i = 0; i < num_recs; i++)
	    {
	    CondRec const& r = recs[i];
	    fprintf( output, "%d:", r.p + 1 );
	    for (int j = 0; j < CLUE_CATEGORY_COUNT; j++)
		{
		ClueCard const c = r.s.v[j];
		if (c != CLUE_CARD_MAX)
		    fprintf( output, " %s", ClueCardName(c) );
		}
	    fprintf( output, "\n" );
	    }
	}
    }
