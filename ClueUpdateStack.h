#ifndef __ClueUpdateStack_h
#define __ClueUpdateStack_h
#ifdef __GNUC__
#pragma interface
#endif
//-----------------------------------------------------------------------------
// ClueUpdateStack.h
//
//	Stack used by ClueAnnaLyzer and ClueDeeDucer to manage book keeping
//	while performing analysis.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueUpdateStack.h,v 1.1 97/05/31 10:12:57 zarnuk Exp $
// $Log:	ClueUpdateStack.h,v $
//  Revision 1.1  97/05/31  10:12:57  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueDefs.h"

class ClueUpdateStack
	{
private:
	struct Rec
		{
		int p;		// player_id or one's complement to negate.
		ClueCard c;	// card.
		};
	int num_recs;
	int max_recs;
	Rec* recs;
	void expand();
public:
	ClueUpdateStack();
	~ClueUpdateStack();
	void push( int p, bool holds, ClueCard c );
	bool pop( int& p, bool& h, ClueCard& c );
	};

#endif // __ClueUpdateStack_h
