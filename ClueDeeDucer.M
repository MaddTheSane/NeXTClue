//-----------------------------------------------------------------------------
// ClueDeeDucer.M
//
//	Clue computer player that analyzes revelations.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueDeeDucer.M,v 1.1 97/05/31 10:10:01 zarnuk Exp $
// $Log:	ClueDeeDucer.M,v $
//  Revision 1.1  97/05/31  10:10:01  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueDeeDucer.h"
#import	"ClueCondArray.h"
#import	"ClueUpdateStack.h"

extern "C" {
#import	<assert.h>
}


@implementation ClueDeeDucer

- (char const*) playerName	{ return "Dee Ducer"; }

//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- (void)dealloc
    {
    delete cond_array;
    { [super dealloc]; return; };
    }


//-----------------------------------------------------------------------------
// dump
//-----------------------------------------------------------------------------
- (void) dump
    {
    [super dump];
    cond_array.dump();
    }


//-----------------------------------------------------------------------------
// fillCheckPlayer:stack:
//-----------------------------------------------------------------------------
- (void) fillCheckPlayer:(int)p stack:(ClueUpdateStack*)stack
    {
    int const num_unknown = num_dealt[p] - num_known[p];
    if (num_unknown > 0)
	{
	int const num_conds = cond_array.countForPlayer( p );
	if (num_conds > 0 && num_conds >= num_unknown)
	    {
	    unsigned int blanks = 0;
	    int const* g = grid[p];
	    int const* const glim = g + CLUE_CARD_COUNT;
	    unsigned int b = 1;
	    for ( ; g < glim; g++, b <<= 1)
		if (*g == GRID_BLANK)
		    blanks |= b;
	
	    unsigned int const conds = cond_array.cardsForPlayer( p );

	    // Every cond-card should be "blank".
	    assert( (conds & blanks) == conds );
	
	    blanks &= ~conds;
	    if (blanks != 0)
		{
		int const min_conds = cond_array.minCardsForPlayer( p );
		if (min_conds >= num_unknown)
		    {
		    b = 1;
		    for (int i = 0; i < CLUE_CARD_COUNT; i++, b <<= 1)
			if ((blanks & b) != 0)
			    {
			    ClueCard const x = ClueCard(i);
			    if (stack != 0)
				stack->push( p, false, x );
			    else
				[self player:p holds:NO card:x];
			    }
		    }
		}
	    }
	}
    }


//-----------------------------------------------------------------------------
// stack:player:holdsCard:
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack player:(int)p holdsCard:(ClueCard)c
    {
    cond_array.holds( p, c );
    [self fillCheckPlayer:p stack:stack];
    [super stack:stack player:p holdsCard:c];
    }


//-----------------------------------------------------------------------------
// stack:player:notHoldsCard:
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack player:(int)p notHoldsCard:(ClueCard)c
    {
    cond_array.not_holds( *stack, p, c );
    [super stack:stack player:p notHoldsCard:c];
    }


//-----------------------------------------------------------------------------
// earlyInit
//-----------------------------------------------------------------------------
- (void) earlyInit
    {
    cond_array = new ClueCondArray;
    [super earlyInit];
    }


//-----------------------------------------------------------------------------
// player:disproves:
//	NOTE *1* If we already know that this player holds one of these
//	cards, then we cannot deduce anything more.
//-----------------------------------------------------------------------------
- (void) player:(int)p disproves:(ClueSolution const*)s
    {
    if (!my_turn)
	{
	bool holds_one = false;
	for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	    if (card_to_player[ s->v[i] ] == p)
		holds_one = true;

	if (!holds_one)		// NOTE *1*
	    {
	    ClueSolution tmp;
	    ClueCard the_card = CLUE_CARD_MAX;
	    int num_blank = 0;
	    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
		{
		ClueCard const c = s->v[i];
		int const x = grid[p][c];
		if (x == GRID_NOT_HOLDS)
		    { tmp.v[i] = CLUE_CARD_MAX; }
		else
		    {
		    assert( x == GRID_BLANK );
		    tmp.v[i] = the_card = c;
		    num_blank++;
		    }
		}
	    if (num_blank == 1)
		[self player:p holds:YES card:the_card];
	    else
		{
		cond_array.add( p, tmp );
		[self fillCheckPlayer:p stack:0];
		}
	    }
	}
    }


//-----------------------------------------------------------------------------
// scoreUnknown:
//	Compute an integer score indicating how much we want to use this
//	card in a suggestion.
//-----------------------------------------------------------------------------
- (int) scoreUnknown:(int)card
    {
    int score = [super scoreUnknown:card];
    score -= cond_array.countContains( ClueCard(card) );

    return score;
    }

@end
