//-----------------------------------------------------------------------------
// ClueCardPicker.cc
//
//	Object used to randomly choose a card with the best score from a
//	list of cards and scores.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#ifdef __GNUC__
#pragma implementation
#endif
#include "ClueCardPicker.h"


void ClueCardPicker::add( int score, ClueCard c )
	{
	int i = n++;		// Insertion sort, descending.
	while (--i >= 0 && a[i].score < score)
	    a[i+1] = a[i];
	i++;
	a[i].score = score;
	a[i].c = c;
	}


ClueCard ClueCardPicker::choose() const
	{
	ClueCard choice = CLUE_CARD_MAX;
	if (n > 0)
	    {
	    int const best_score = a[0].score;
	    int i = 1;
	    while (i < n && a[i].score == best_score)
		i++;
	    choice = a[ random_int(i) ].c;
	    }
	return choice;
	}
