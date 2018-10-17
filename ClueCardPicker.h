#ifndef __ClueCardPicker_h
#define __ClueCardPicker_h
#ifdef __GNUC__
#pragma interface
#endif
//-----------------------------------------------------------------------------
// ClueCardPicker.h
//
//	Object used to randomly choose a card with the best score from a
//	list of cards and scores.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueCardPicker.h,v 1.1 97/05/31 10:07:51 zarnuk Exp $
// $Log:	ClueCardPicker.h,v $
//  Revision 1.1  97/05/31  10:07:51  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueDefs.h"

class ClueCardPicker
	{
private:
	struct Rec
		{
		int score;
		ClueCard c;
		};
	int n;
	Rec a[ CLUE_CARD_MAX ];
public:
	ClueCardPicker(): n(0) {}
	void add( int score, ClueCard c );
	ClueCard choose() const;
	};

#endif // __ClueCardPicker_h
