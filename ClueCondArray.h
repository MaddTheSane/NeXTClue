#ifndef __ClueCondArray_h
#define __ClueCondArray_h
#ifdef __GNUC__
#pragma interface
#endif
//-----------------------------------------------------------------------------
// ClueCondArray.h
//
//	List of conditional deductions exposed during play for use by the
//	ClueDeeDucer computer player.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#ifndef __ClueDefs_h
#include "ClueDefs.h"
#endif

class ClueUpdateStack;

class ClueCondArray			// Array of conditional expressions.
	{
private:
	struct CondRec
		{
		int		p;	// This player holds at least one of
		ClueSolution	s;	// these cards.  (CLUE_CARD_MAX=blank)
		};

	int num_recs;
	int max_recs;
	CondRec* recs;

mutable	ClueCardSet curr_set;		// Used by min_cards()
mutable	int curr_player;
mutable	int curr_len;
mutable	int min_len;
	void min_cards( int i ) const;

	void expand();
	void append( CondRec const& r );
	void append( int p, ClueSolution const& s );
	void deleteAt( int n );
	void removeSupersets( int p, ClueSolution const& s );
	bool findSubset( int p, ClueSolution const& s ) const;

public:
	ClueCondArray();
	~ClueCondArray();
	void add( int p, ClueSolution const& s );
	void holds( int p, ClueCard c );
	void not_holds( ClueUpdateStack& stack, int p, ClueCard c );
	int countContains( ClueCard c ) const;
	int countForPlayer( int p ) const;
static	ClueCardSet cardsForCond( ClueSolution const& s );
	ClueCardSet cardsForPlayer( int p ) const;
	int minCardsForPlayer( int p ) const;
	void dump() const;
	};

#endif // __ClueCondArray_h
