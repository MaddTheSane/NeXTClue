//-----------------------------------------------------------------------------
// ClueAnnaLyzer.M
//
//	Clue computer player that analyzes revelations.
//
// FIXME: Should not bother testing unknown rooms if we have already solved
// the room category.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueAnnaLyzer.M,v 1.1 97/05/31 10:06:23 zarnuk Exp $
// $Log:	ClueAnnaLyzer.M,v $
//  Revision 1.1  97/05/31  10:06:23  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueAnnaLyzer.h"
#import "ClueCardPicker.h"
#import "ClueUpdateStack.h"
#import <Foundation/Foundation.h>

extern "C" {
#import	<assert.h>
#import	<stdio.h>
}


//-----------------------------------------------------------------------------
// complete
//-----------------------------------------------------------------------------
inline bool complete( ClueSolution const& s )
{
    return	s.suspect() != CLUE_CARD_MAX &&
    s.weapon() != CLUE_CARD_MAX &&
    s.room() != CLUE_CARD_MAX;
}



@implementation ClueAnnaLyzer
- (NSString*) playerName	{ return @"Anna Lyzer"; }

//-----------------------------------------------------------------------------
// dump
//-----------------------------------------------------------------------------
- (void) dump
{
    FILE* output = stdout;
    int const NUM_PLAYERS = [self numPlayers];

    fprintf( output, "\n\%s:%d\n", [(NSString*)[[self class] name] UTF8String], [self playerID] + 1 );

    fprintf( output, "solution:" );
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
    {
        ClueCard const c = solution.v[i];
        if (c != CLUE_CARD_MAX)
            fprintf( output, " %s", ClueCardName(c) );
    }
    fprintf( output, "\n" );

    for (int p = 0; p < NUM_PLAYERS; p++)
        fprintf( output, "%d ", p + 1 );
    fprintf( output, " [held-by]\n" );

    for (int c = 0; c < CLUE_CARD_COUNT; c++)
    {
        for (int p = 0; p < NUM_PLAYERS; p++)
        {
            int const g = grid[p][c];
            switch (g)
            {
                case GRID_BLANK: fprintf( output, "  " ); break;
                case GRID_HOLDS: fprintf( output, "x " ); break;
                case GRID_NOT_HOLDS: fprintf( output, "- " ); break;
                default: fprintf( output, "%d ", g ); break;
            }
        }
        fprintf( output, " [%d] %s\n", card_to_player[c] + 1,
                ClueCardName( ClueCard(c) ) );
    }
}


//-----------------------------------------------------------------------------
// stack:fillPlayer:holds:
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack fillPlayer:(int)p holds:(BOOL)h
{
    for (int c = 0; c < CLUE_CARD_COUNT; c++)
        if (grid[p][c] == GRID_BLANK)
            stack->push( p, h, ClueCard(c) );
}


//-----------------------------------------------------------------------------
// stack:player:holdsCard:
//
// NOTE *1*
//	If player 'p' holds card 'c', then all other players do NOT hold 'c'.
//
// NOTE *2*
//	If we have identified all the cards that player 'p' is holding, then
//	player 'p' is NOT holding any other cards.
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack player:(int)p holdsCard:(ClueCard)c
{
    int const NUM_PLAYERS = [self numPlayers];

    assert( card_to_player[c] == PLAYER_UNKNOWN );
    card_to_player[c] = p;

    for (int i = 0; i < NUM_PLAYERS; i++)	// NOTE *1*
        if (i != p && grid[i][c] == GRID_BLANK)
            stack->push( i, false, c );

    if (++num_known[p] == num_dealt[p])		// NOTE *2*
        [self stack:stack fillPlayer:p holds:NO];
}


//-----------------------------------------------------------------------------
// stack:player:notHoldsCard:
//
// NOTE *3*
//	Inverse of *2*.  If there are 'n' cards that are not known for
//	player 'p', and we have exactly 'n' blank entries in his row (all
//	other entries marked as HOLDS or NOT_HOLDS), then the blank entries
//	must represent the remaining unknown cards for player 'p'.
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack player:(int)p notHoldsCard:(ClueCard)c
{
    int const NUM_PLAYERS = [self numPlayers];

    int j = 0;
    for (j = 0; j < NUM_PLAYERS; j++)
        if (grid[j][c] != GRID_NOT_HOLDS)
            break;

    if (j == NUM_PLAYERS)	// Found solution for this category.
    {
        ClueCategory const cat = ClueCardCategory(c);
        assert( card_to_player[c] == PLAYER_UNKNOWN );
        card_to_player[c] = PLAYER_SOLUTION;
        assert( solution.v[cat] == CLUE_CARD_MAX );
        solution.v[cat] = c;
    }

    int nblank = 0;
    for (int i = 0; i < CLUE_CARD_COUNT; i++)
        if (grid[p][i] == GRID_BLANK)
            nblank++;

    if (nblank > 0 && nblank + num_known[p] == num_dealt[p])
        [self stack:stack fillPlayer:p holds:YES];	// NOTE *3*
}


//-----------------------------------------------------------------------------
// stack:checkCard:
//
// NOTE *4*
//	If the category is not solved and there is only one card in the 
//	category that is not assigned to a player, then it must be the 
//	solution for the category.  
//
// NOTE *5*
//	If the category is solved, then remaining cards in that category 
//	with a single BLANK should become HOLDS.  
//
// NOTE *6*
//	If the category has been solved, then any other cards in that
//	category must be held by a player.  If there is a card where all
//	players but one are marked as NOT holds, then the remaining player
//	HOLDS the card.
//-----------------------------------------------------------------------------
- (void) stack:(ClueUpdateStack*)stack checkCard:(ClueCard)card
{
    int const NUM_PLAYERS = [self numPlayers];
    ClueCategory const cat = ClueCardCategory(card);
    int const cat_first = CLUE_CATEGORY_RANGE[ cat ].first;
    int const cat_last  = CLUE_CATEGORY_RANGE[ cat ].last;

    if (solution.v[cat] == CLUE_CARD_MAX)	// Category not solved.
    {					// NOTE *4*
        int n = 0;
        int the_card = CLUE_CARD_MAX;
        for (int c = cat_first; c <= cat_last; c++)
            if (card_to_player[c] == PLAYER_UNKNOWN)
            { the_card = c; n++; }
        if (n == 1)
            for (int p = 0; p < NUM_PLAYERS; p++)
                if (grid[p][the_card] == GRID_BLANK)
                    stack->push( p, false, ClueCard(the_card) );
    }
    else						// Category solved
    {						// NOTE *5*
        for (int c = cat_first; c <= cat_last; c++)
            if (card_to_player[c] == PLAYER_UNKNOWN)
            {
                int n = 0;
                int x = -1;
                for (int p = 0; p < NUM_PLAYERS; p++)
                    if (grid[p][c] == GRID_BLANK)
                    { x = p; n++; }
                if (n == 1)
                    stack->push( x, true, ClueCard(c) );	// NOTE *6*
            }
    }
}


//-----------------------------------------------------------------------------
// player:holds:card:
//	A new fact has been revealed.  Update the grid, and propagate any
//	additional facts derived from this fresh piece of information.
//-----------------------------------------------------------------------------
- (void) player:(int)player holds:(BOOL)holds card:(ClueCard)card
{
    int p = player;
    bool h = (bool) holds;
    ClueCard c = card;

    ClueUpdateStack stack;
    do  {
        int const x = (h ? GRID_HOLDS : GRID_NOT_HOLDS);
        int& g = grid[p][c];
        if (g == GRID_BLANK)		// A change to the grid.
        {
            g = x;			// Update the grid.
            if (h)
                [self stack:&stack player:p holdsCard:c];
            else
                [self stack:&stack player:p notHoldsCard:c];
            
            [self stack:&stack checkCard:c];
        }
        else
            assert( g == x );	// else we have a contradiction.
    }
    while (stack.pop( p, h, c ));
    //      [self dump];
}


//-----------------------------------------------------------------------------
// initGrid
//	The grid[][] is initialized to zero by the normal Objective-C
//	object allocation/initialization stuff.  We take advantage of
//	that by interpreting zero as "unknown" in the grid, so most of
//	the grid is properly initialized "unknown" when we start.  This
//	routine takes the cards that we were dealt and updates the grid
//	to reflect this starting information.
//-----------------------------------------------------------------------------
- (void) initGrid
{
    int const self_id = [self playerID];
    ClueCard const* const c0 = [self cards];
    ClueCard const* const clim = c0 + [self numCards];
    for (ClueCard const* c = c0; c < clim; c++)
        [self player:self_id holds:YES card:*c];
}


//-----------------------------------------------------------------------------
// initNumDealt
//	num_known[] is initialized to zeroes by the standard Objective-C
//	alloc/init mechanism.
//-----------------------------------------------------------------------------
- (void) initNumDealt
{
    int const NUM_PLAYERS = [self numPlayers];
    int const NUM_CARDS_DEALT = CLUE_CARD_COUNT - CLUE_CATEGORY_COUNT;
    int const ncards = NUM_CARDS_DEALT / NUM_PLAYERS;
    int const nextra = NUM_CARDS_DEALT % NUM_PLAYERS;

    int i = 0;
    for ( ; i < nextra; i++)		// The first few players get the
        num_dealt[i] = ncards + 1;	// extra cards.

    for ( ; i < NUM_PLAYERS; i++)
        num_dealt[i] = ncards;
}


//-----------------------------------------------------------------------------
// earlyInit
//-----------------------------------------------------------------------------
- (void) earlyInit
    {}


//-----------------------------------------------------------------------------
// lateInit
//-----------------------------------------------------------------------------
- (void) lateInit
    {}


//-----------------------------------------------------------------------------
// initPlayer:numPlayers:numCards:cards:piece:location:
//	num_known[] and grid[][] are initialized to 0 by the standard
//	Objective-C [Object alloc].
//-----------------------------------------------------------------------------
- initPlayer:(int)playerID numPlayers:(int)numPlayers
    numCards:(int)numCards cards:(ClueCard const*)i_cards
       piece:(ClueCard)pieceID location:(ClueCoord)i_location
     clueMgr:(ClueMgr*)mgr
{
    int i;
    [super initPlayer:playerID numPlayers:numPlayers
             numCards:numCards cards:i_cards
                piece:pieceID location:i_location clueMgr:mgr];

    [self earlyInit];

    solution.suspect() = CLUE_CARD_MAX;
    solution.weapon() = CLUE_CARD_MAX;
    solution.room() = CLUE_CARD_MAX;

    for (i = 0; i < CLUE_CARD_COUNT; i++)
        card_to_player[i] = PLAYER_UNKNOWN;

    [self initNumDealt];
    [self initGrid];

    [self lateInit];

    return self;
}


//-----------------------------------------------------------------------------
// player:cannotDisprove:
//-----------------------------------------------------------------------------
- (void) player:(int)p cannotDisprove:(ClueSolution const*)s
{
    if (p != [self playerID])
        for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
            [self player:p holds:NO card:s->v[i]];
}


//-----------------------------------------------------------------------------
// player:reveals:
//-----------------------------------------------------------------------------
- (void) player:(int)p reveals:(ClueCard)card
{
    [self player:p holds:YES card:card];
    [self revealOk];
}


//-----------------------------------------------------------------------------
// scoreUnknown:
//	Compute an integer score indicating how much we want to use this
//	card in a suggestion.
//-----------------------------------------------------------------------------
- (int) scoreUnknown:(int)card
{
    int score = 0;
    
    for (int p = [self numPlayers]; p-- > 0; )
        if (grid[p][card] == GRID_NOT_HOLDS)
            score++;

    return score;
}


//-----------------------------------------------------------------------------
// suggestUnknown:
//	Select an unknown card in this category to use in a suggestion.
//	If we have already solved this category, then use the solution
//	from this category, so that our suggestion will not get disproved
//	by a player revealing a card for a category that we've already
//	solved.
//-----------------------------------------------------------------------------
- (ClueCard) suggestUnknown:(int) category
{
    ClueCard answer = solution.v[category];
    if (answer == CLUE_CARD_MAX)
    {
        ClueCardPicker picker;

        int const c0 = CLUE_CATEGORY_RANGE[ category ].first;
        int const cN = CLUE_CATEGORY_RANGE[ category ].last;
        for (int c = c0; c <= cN; c++)
            if (card_to_player[c] == PLAYER_UNKNOWN)
                picker.add( [self scoreUnknown:c], ClueCard(c) );

        answer = picker.choose();
    }
    return answer;
}


//-----------------------------------------------------------------------------
// suggestKnown:
//-----------------------------------------------------------------------------
- (ClueCard) suggestKnown:(int)category
{
    ClueCardPicker picker;

    int const self_id = [self playerID];
    int const c0 = CLUE_CATEGORY_RANGE[category].first;
    int const cN = CLUE_CATEGORY_RANGE[category].last;
    for (int c = c0; c <= cN; c++)
        if (card_to_player[c] == self_id)
        {
            int n = 0;
            for (unsigned int x = (unsigned int) revealed[c]; x != 0; x >>= 1)
                if ((x & 1) != 0)
                    n++;
            picker.add( CLUE_NUM_PLAYERS_MAX - n, ClueCard(c) );
        }

    return picker.choose();
}


//-----------------------------------------------------------------------------
// suggest:unknown:known:
//-----------------------------------------------------------------------------
- (void) suggest:(ClueSolution*)buff
	unknown:(ClueSolution const*)unknown
	known:(ClueSolution const*)known
{
    *buff = *unknown;			// Use unknown cards by default.

    int nsolved = 0;
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
        if (solution.v[i] != CLUE_CARD_MAX)
        {
            nsolved++;
            ClueCard const c = known->v[i];
            if (c != CLUE_CARD_MAX)
                buff->v[i] = c;		// Avoid using the solution.
        }

    if (nsolved == 0)
    {
        int const k = random_int( CLUE_CATEGORY_COUNT + 1 );
        if (k < CLUE_CATEGORY_COUNT)
        {
            ClueCard const c = known->v[k];
            if (c != CLUE_CARD_MAX)
                buff->v[k] = c;
        }
    }
}


//-----------------------------------------------------------------------------
// makeSuggestion
//-----------------------------------------------------------------------------
- (void) makeSuggestion
{
    ClueSolution const* p = 0;
    ClueCard const curr_room = ClueRoomAt( [self location] );
    if (curr_room != CLUE_CARD_MAX && curr_room != last_room)
    {
        ClueSolution unknown;	// Cards that we do not hold.
        ClueSolution known;	// Cards that we do hold.
        
        unknown.suspect() = [self suggestUnknown: CLUE_CATEGORY_SUSPECT];
        unknown.weapon() = [self suggestUnknown: CLUE_CATEGORY_WEAPON];
        unknown.room() = curr_room;
        
        known.suspect() = [self suggestKnown: CLUE_CATEGORY_SUSPECT];
        known.weapon() = [self suggestKnown: CLUE_CATEGORY_WEAPON];
        known.room() = curr_room;
        
        [self suggest:&suggestion unknown:&unknown known:&known];
        p = &suggestion;
    }

    [self suggest:p];
}


//-----------------------------------------------------------------------------
// makeAccusation
//-----------------------------------------------------------------------------
- (void) makeAccusation
{
    ClueSolution* p = 0;
    if (complete( solution ))
        p = &solution;
    [self accuse:p];
}


//-----------------------------------------------------------------------------
// disprove:forPlayer:
//-----------------------------------------------------------------------------
- (void) disprove:(ClueSolution const*)s forPlayer:(int)p
{
    ClueCardPicker picker;

    int const pb = (1 << p);

    int const self_id = [self playerID];
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
    {
        ClueCard const c = s->v[i];
        if (card_to_player[c] == self_id)
        {
            int score = 0;
            int const x = revealed[c];
            if (x != 0)			// Ever revealed to anybody?
                score |= 1;
            if ((x & pb) != 0)		// Ever revealed to this player?
                score |= 2;
            picker.add( score, c );
        }
    }

    ClueCard const card = picker.choose();

    revealed[ card ] |= pb;

    [self reveal:card];
}


//-----------------------------------------------------------------------------
// wantToStay:
//	We want to stay in this room to make a suggestion if we do not know
//	who holds this room, or if this room is in the solution, or if we
//	hold this room and the weapon and/or suspect category has not been
//	solved yet.
//-----------------------------------------------------------------------------
- (BOOL) wantToStay:(ClueCard)room
{
    int const holder = card_to_player[ room ];
    return	holder == PLAYER_UNKNOWN ||
    holder == PLAYER_SOLUTION ||
    (holder == [self playerID] &&
     (solution.suspect() == CLUE_CARD_MAX ||
      solution.weapon() == CLUE_CARD_MAX));
}


//-----------------------------------------------------------------------------
// chooseGoalRoom
//-----------------------------------------------------------------------------
- (ClueCard) chooseGoalRoom
{
    int n = 0;
    ClueCard buff[ CLUE_ROOM_COUNT ];
    
    int const self_id = [self playerID];
    BOOL const self_ok = (solution.suspect() == CLUE_CARD_MAX ||
                          solution.weapon() == CLUE_CARD_MAX);
    
    for (int i = CLUE_ROOM_FIRST; i < CLUE_ROOM_LAST; i++)
    {
        int const x = card_to_player[i];
        if (x == PLAYER_UNKNOWN || x == PLAYER_SOLUTION ||
            x == self_id && self_ok)
            buff[ n++ ] = ClueCard(i);
    }
    
    return [self chooseClosest:buff count:n];
}

@end
