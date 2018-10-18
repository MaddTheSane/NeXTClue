//-----------------------------------------------------------------------------
// ClueCyBorg.M
//
//	Computer player that goes beyond mere logic.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueCyBorg.M,v 1.1 97/05/31 10:10:26 zarnuk Exp $
// $Log:	ClueCyBorg.M,v $
//  Revision 1.1  97/05/31  10:10:26  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueCyBorg.h"
#import	"ClueCondArray.h"

extern "C" {
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>	// malloc(), realloc(), free()
}


//=============================================================================
// ClueHistory
//=============================================================================
class ClueHistory
	{
public:
	int const NOT_SET = -1;
	int const NOBODY = -2;
private:
	struct Rec
		{
		int suggested_by;	// Player ID.
		int disproved_by;	// Player ID, or NOT_SET, or NOBODY.
		ClueSolution s;
		};
	int num_recs;
	int max_recs;
	Rec* recs;
	void expand();
	void set_disproved_by( int p );
public:
	ClueHistory();
	~ClueHistory()			{ free( recs ); }
	void suggests( int p, ClueSolution const& );
	void disproves( int p )		{ set_disproved_by( p ); }
	void nobodyDisproves()		{ set_disproved_by( NOBODY ); }
	int count() const		{ return num_recs; }
	Rec const& nth( int n ) const	{ return recs[n]; }
	Rec& nth( int n )		{ return recs[n]; }
	};


//-----------------------------------------------------------------------------
// Constructor
//-----------------------------------------------------------------------------
ClueHistory::ClueHistory()
    {
    num_recs = 0;
    max_recs = 32;
    recs = (Rec*) malloc( max_recs * sizeof(*recs) );
    }


//-----------------------------------------------------------------------------
// expand
//-----------------------------------------------------------------------------
void ClueHistory::expand()
    {
    max_recs += max_recs;
    recs = (Rec*) realloc( recs, max_recs * sizeof(*recs) );
    }


//-----------------------------------------------------------------------------
// suggests
//-----------------------------------------------------------------------------
void ClueHistory::suggests( int p, ClueSolution const& s )
    {
    if (num_recs >= max_recs) expand();
    Rec& r = recs[ num_recs++ ];
    r.suggested_by = p;
    r.disproved_by = NOT_SET;
    r.s = s;
    }


//-----------------------------------------------------------------------------
// set_disproved_by
//-----------------------------------------------------------------------------
void ClueHistory::set_disproved_by( int p )
    {
    assert( num_recs > 0 );
    Rec& r = recs[ num_recs - 1 ];
    assert( r.disproved_by == NOT_SET );
    r.disproved_by = p;
    }


//=============================================================================
// IMPLEMENTATION
//=============================================================================
@implementation ClueCyBorg

- (NSString*) playerName	{ return @"Cy Borg"; }

//-----------------------------------------------------------------------------
// updateProb:player:card:
//-----------------------------------------------------------------------------
- (void) updateProb:(float)delta player:(int)player card:(int)card
    {
    int p;

    probs[player][card] += delta;

    float sum = 0;
    int nblank = 0;
    for (p = 0; p < num_players; p++)
	if (p != player && grid[p][card] == GRID_BLANK)
	    {
	    nblank++;
	    sum += probs[p][card];
	    }

    if (player != num_players)
	{
	nblank++;
	sum += probs[num_players][card];
	}

    if (nblank > 0 && sum != 0)
	{
	float const factor = (sum - delta) / sum;
	for (p = 0; p < num_players; p++)
	    if (p != player && grid[p][card] == GRID_BLANK)
		probs[p][card] *= factor;
	if (player != num_players)
	    probs[num_players][card] *= factor;
	}
    }


//-----------------------------------------------------------------------------
// fixCategory:
//	Normalize the solution probabilities in this category so that the
//	probabilities of the various cards adds up to unity.
//-----------------------------------------------------------------------------
- (void) fixCategory:(int)cat
    {
    float const EPSILON = 0.00001;
    int const lo = CLUE_CATEGORY_RANGE[cat].first;
    int const hi = CLUE_CATEGORY_RANGE[cat].last;

    int c;
    float sum = 0;
    for (c = lo; c <= hi; c++)
	sum += probs[num_players][c];

    if (sum < 1.0 - EPSILON || 1.0 + EPSILON < sum)
	{
	float const inv_sum = 1.0 / sum;
	for (c = lo; c <= hi; c++)
	    {
	    float const old_val = probs[num_players][c];
	    if (old_val < -EPSILON || EPSILON < old_val)
		{
		float const new_val = old_val * inv_sum;
		float const delta = new_val - old_val;
		if (delta < -EPSILON || EPSILON < delta)
		    [self updateProb:delta player:num_players card:c];
		}
	    }
	}
    }


//-----------------------------------------------------------------------------
// fixCategories
//	Normalize all categories.
//-----------------------------------------------------------------------------
- (void) fixCategories
    {
    [self fixCategory:CLUE_CATEGORY_SUSPECT];
    [self fixCategory:CLUE_CATEGORY_WEAPON];
    [self fixCategory:CLUE_CATEGORY_ROOM];
    }


//-----------------------------------------------------------------------------
// setProb:player:card:
//-----------------------------------------------------------------------------
- (void) setProb:(float)val player:(int)player card:(int)card
    {
    int c;
    
    float const delta = val - probs[player][card];

    [self updateProb:delta player:player card:card];

    if (player < num_players)
	{
	float sum = 0;
	int nblank = 0;
	for (c = 0; c < CLUE_CARD_COUNT; c++)
	    if (c != card && grid[player][c] == GRID_BLANK)
		{
		sum += probs[player][c];
		nblank++;
		}
    
	if (nblank > 0)
	    {
	    float const factor = (sum - delta) / sum;
	    for (c = 0; c < CLUE_CARD_COUNT; c++)
		if (c != card && grid[player][c] == GRID_BLANK)
		    {
		    float const old_val = probs[player][c];
		    float const new_val = old_val * factor;
		    float const delta = new_val - old_val;
		    [self updateProb:delta player:player card:c];
		    }
	    }
	}
    }


//-----------------------------------------------------------------------------
// decrease:player:set:
//-----------------------------------------------------------------------------
- (void) decrease:(float)factor player:(int)p set:(ClueSolution const*)s
    {
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	{
	int const c = s->v[i];
	if (c != CLUE_CARD_MAX && grid[p][c] == GRID_BLANK)
	    {
	    float const old_val = probs[p][c];
	    float const new_val = old_val * factor;
	    [self setProb:new_val player:p card:c];
	    }
	}
    }


//-----------------------------------------------------------------------------
// increase:player:set:
//-----------------------------------------------------------------------------
- (void) increase:(float)factor player:(int)p set:(ClueSolution const*)s
    {
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	{
	int const c = s->v[i];
	if (c != CLUE_CARD_MAX && grid[p][c] == GRID_BLANK)
	    {
	    float const old_val = probs[p][c];
	    float const new_val = old_val + (1.0 - old_val) * factor;
	    [self setProb:new_val player:p card:c];
	    }
	}
    }


//-----------------------------------------------------------------------------
// player:suggests:
//
//	If any of these cards were "disproved" for this player before, then 
//	decrease the probabilty that the disproved_by player holds those 
//	cards.  (As long as player 'p' is not RandyMizer).  
//
//	Also, register a slight decrease in probability for cards that
//	a player is suggesting.
//-----------------------------------------------------------------------------
- (void) player:(int)p suggests:(ClueSolution const*)s
    {
    [super player:p suggests:s];
    assert( s != 0 );

    int const lim = history->count();
    for (int i = 0; i < lim; i++)
	{
	ClueSolution tmp;
	ClueHistory::Rec const& r = history->nth(i);
	if (r.suggested_by == p && r.disproved_by != ClueHistory::NOBODY)
	    {
	    BOOL have_one = NO;
	    for (int j = 0; j < CLUE_CATEGORY_COUNT; j++)
		if (s->v[j] == r.s.v[j])
		    { tmp.v[j] = s->v[j]; have_one = YES; }
		else
		    tmp.v[j] = CLUE_CARD_MAX;
	    if (have_one)			// LARGE_DECREASE
		[self decrease:0.5 player:r.disproved_by set:&tmp];
	    }
	}

    [self decrease:0.75 player:p set:s];	// SMALL_DECREASE
    [self fixCategories];

    history->suggests( p, *s );
    }


//-----------------------------------------------------------------------------
// player:holdsOne:
//-----------------------------------------------------------------------------
- (BOOL) player:(int)p holdsOne:(ClueSolution const*)s
    {
    return	card_to_player[ s->suspect() ] == p ||
		card_to_player[ s->weapon() ] == p ||
		card_to_player[ s->room() ] == p;
    }


//-----------------------------------------------------------------------------
// player:disproves:
//-----------------------------------------------------------------------------
- (void) player:(int)p disproves:(ClueSolution const*)s
    {
    [super player:p disproves:s];
    history->disproves( p );
    if (![self player:p holdsOne:s])
	[self increase:0.5 player:p set:s];	// LARGE_INCREASE
    }


//-----------------------------------------------------------------------------
// nobodyDisproves:
//-----------------------------------------------------------------------------
- (void) nobodyDisproves:(ClueSolution const*)s
    {
    [super nobodyDisproves:s];
    history->nobodyDisproves();
    }


//-----------------------------------------------------------------------------
// stack:player:holdsCard:
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack player:(int)p holdsCard:(ClueCard)c
    {
    [super stack:stack player:p holdsCard:c];
    if (did_init)
	{
	nailed[c] = YES;
	[self setProb:1 player:p card:c];
	[self fixCategories];
	}
    }


//-----------------------------------------------------------------------------
// stack:player:notHoldsCard:
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack player:(int)p notHoldsCard:(ClueCard)c
    {
    [super stack:stack player:p notHoldsCard:c];
    if (did_init && !nailed[c])
	{
	[self setProb:0 player:p card:c];
	if (card_to_player[c] == PLAYER_SOLUTION)
	    {
	    nailed[c] = YES;
	    int const cat = ClueCardCategory(c);
	    int const lo = CLUE_CATEGORY_RANGE[cat].first;
	    int const hi = CLUE_CATEGORY_RANGE[cat].last;
	    for (int i = lo; i <= hi; i++)
		if (i != c)
		    [self setProb:0 player:num_players card:i];
	    [self setProb:1 player:num_players card:c];
	    }
	[self fixCategories];
	}
    }


//-----------------------------------------------------------------------------
// scoreUnknown:
//	Compute an integer score indicating how much we want to use this
//	card in a suggestion.
//-----------------------------------------------------------------------------
- (int) scoreUnknown:(int)card
    {
    return int( 100.0 * probs[num_players][card] );
    }


//-----------------------------------------------------------------------------
// initProbsCategory:
//-----------------------------------------------------------------------------
- initProbsCategory:(int)cat
    {
    assert( num_players > 1 );

    int const lo = CLUE_CATEGORY_RANGE[cat].first;
    int const hi = CLUE_CATEGORY_RANGE[cat].last;
    int const ncards = hi - lo + 1;
    assert( ncards > 0 );

    int i,j;
    int ndealt = 0;
    int const self_id = [self playerID];
    int const* g = grid[ self_id ];
    for (i = lo; i <= hi; i++)
	if (g[i] == GRID_HOLDS)
	    {
	    ndealt++;
	    for (j = 0; j <= num_players; j++)
		probs[j][i] = 0;
	    probs[self_id][i] = 1;
	    }

    int const num_unknown = ncards - ndealt;
    assert( num_unknown > 0 );

    float soln_prob = 1;	// Probability card is in solution.
    float pone_prob = 0;	// Probability card is held by opponent.

    if (num_unknown > 1)
	{
	soln_prob = 1.0 / float( num_unknown );
	pone_prob = (1.0 - soln_prob) / float( num_players - 1 );
	}

    g = grid[ self_id ];
    for (i = lo; i <= hi; i++)
	if (g[i] == GRID_NOT_HOLDS)
	    {
	    for (j = 0; j < num_players; j++)
		probs[j][i] = pone_prob;
	    probs[num_players][i] = soln_prob;
	    probs[self_id][i] = 0;
	    }
    }


//-----------------------------------------------------------------------------
// initProbs
//	Initialize the probability grid.
//-----------------------------------------------------------------------------
- (void) initProbs
    {
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	[self initProbsCategory:i];
    }


//-----------------------------------------------------------------------------
// lateInit
//-----------------------------------------------------------------------------
- (void) lateInit
    {
    [self initProbs];
    did_init = YES;
    [super lateInit];
    }


//-----------------------------------------------------------------------------
// earlyInit
//-----------------------------------------------------------------------------
- (void) earlyInit
    {
    did_init = NO;
    [super earlyInit];
    history = new ClueHistory;
    }


//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- (void)dealloc
    {
    delete history;
    { [super dealloc]; return; };
    }

//-----------------------------------------------------------------------------
// dump
//-----------------------------------------------------------------------------
- (void) dump
    {
    [super dump];

    FILE* output = stdout;

    int p, c;
    float col_sum[ CLUE_NUM_PLAYERS_MAX+1];

    fprintf( output, "Probability distributions.\n" );

    for (p = 0; p <= num_players; p++)
	{
	col_sum[ p ] = 0;
	fprintf( output, "    %d   ", p + 1 );
	}
    fprintf( output, " (row sum)\n" );


    float cat_sum = 0;
    ClueCategory cat = CLUE_CATEGORY_SUSPECT;
    int cat_last = CLUE_CATEGORY_RANGE[ cat ].last;

    for (c = 0; c < CLUE_CARD_COUNT; c++)
	{
	float row_sum = 0;

	for (p = 0; p <= num_players; p++)
	    {
	    float const x = probs[p][c];
	    col_sum[p] += x;
	    row_sum += x;
	    fprintf( output, " %7.4f", x );
	    }
	fprintf( output, " %7.4f\n", row_sum );

	cat_sum += probs[num_players][c];
	if (c == cat_last)
	    {
	    fprintf( output, "%*s %7.4f (category sum)\n\n",
				num_players * 8, "", cat_sum );
	    if (cat < CLUE_CATEGORY_MAX)
		{
		cat = ClueCategory( int(cat) + 1 );
		cat_last = CLUE_CATEGORY_RANGE[ cat ].last;
		cat_sum = 0;
		}
	    }
	}

    for (p = 0; p <= num_players; p++)
	fprintf( output, " %7.4f", col_sum[p] );
    fprintf( output, " (col sum)\n" );

    fprintf( output, "\n" );
    }

@end
