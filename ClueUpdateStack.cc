//-----------------------------------------------------------------------------
// ClueUpdateStack.cc
//
//	Stack used by ClueAnnaLyzer and ClueDeeDucer to manage book keeping
//	while performing analysis.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueUpdateStack.cc,v 1.1 97/05/31 10:13:02 zarnuk Exp $
// $Log:	ClueUpdateStack.cc,v $
//  Revision 1.1  97/05/31  10:13:02  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#ifdef __GNUC__
#pragma implementation
#endif
#import "ClueUpdateStack.h"

#import	<cstdlib>


void ClueUpdateStack::expand()
{
	max_recs += max_recs;
	recs = (Rec*) realloc( recs, max_recs * sizeof(*recs) );
}


ClueUpdateStack::ClueUpdateStack():num_recs(0),max_recs(8)
{ recs = (Rec*) malloc( max_recs * sizeof(*recs) ); }


ClueUpdateStack::~ClueUpdateStack()
{ free( recs ); }


void ClueUpdateStack::push( int p, bool holds, ClueCard c )
{
	if (num_recs >= max_recs) expand();
	Rec& r = recs[ num_recs++ ];
	r.p = (holds ? p : ~p);
	r.c = c;
}


bool ClueUpdateStack::pop( int& p, bool& h, ClueCard& c )
{
	if (num_recs > 0)
	{
		Rec& r = recs[ --num_recs ];
		c = r.c;
		int const t = r.p;
		if (t >= 0)
		{
			h = true;
			p = t;
		}
		else
		{
			h = false;
			p = ~t;
		}
		return true;
	}
	return false;
}

