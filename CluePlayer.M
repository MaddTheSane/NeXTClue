//-----------------------------------------------------------------------------
// CluePlayer.M
//
//	Base class for player objects in the Clue app.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import	"CluePlayer.h"
#import	"ClueDefs.h"
#import	"ClueMgr.h"
extern "Objective-C" {
#import	<appkit/Application.h>	// for perform:with:afterDelay:cancelPrevious:
}
extern "C" {
#import <string.h>	// memcpy
}

@implementation CluePlayer

- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)i_cards
	piece:(ClueCard)pieceID location:(ClueCoord)i_location
	clueMgr:(ClueMgr*)mgr
    {
    [super init];
    player_id = playerID;
    num_players = numPlayers;
    num_cards = numCards;
    memcpy( cards, i_cards, numCards * sizeof(*cards) );
    piece_id = pieceID;
    location = i_location;
    clueMgr = mgr;
    return self;
    }

- (int) playerID		{ return player_id; }
- (int) numPlayers		{ return num_players; }
- (int) numCards		{ return num_cards; }
- (ClueCard const*) cards	{ return cards; }
- (ClueCard) pieceID		{ return piece_id; }
- (ClueCoord) location		{ return location; }
- (ClueMgr*) clueMgr		{ return clueMgr; }

- (char const*) playerName	{ return [[self class] name]; }

- (BOOL) canAccuse		{ return YES; }
- (BOOL) canSuggest		{ return YES; }
- (BOOL) isHuman		{ return NO; }

- (BOOL) amHoldingCard:(ClueCard)card
    {
    ClueCard const* c = [self cards];
    ClueCard const* const clim = c + [self numCards];
    for ( ; c < clim; c++)
	if (*c == card)
	    return YES;
    return NO;
    }


//-----------------------------//
// DIALOGUE RESPONSE MECHANISM //
//-----------------------------//

- (void) direct:(SEL)aSel
    { [clueMgr perform:aSel with:self afterDelay:0 cancelPrevious:NO]; }

- (void) nextPlayerOk		{ [self direct:@selector(nextPlayerOk:)]; }
- (void) revealOk		{ [self direct:@selector(revealOk:)]; }


- (void) delayed:(SEL)aSel
    { [self perform:aSel with:0 afterDelay:0 cancelPrevious:NO]; }


- (void) cp_do_move:sender	{ [clueMgr moveTo:cp_coord ok:self]; }
- (void) moveTo:(ClueCoord)coord
	{ cp_coord = coord; [self delayed:@selector(cp_do_move:)]; }


- (void) cp_do_reveal:sender	{ [clueMgr reveal:cp_card ok:self]; }
- (void) reveal:(ClueCard)x
	{ cp_card = x; [self delayed:@selector(cp_do_reveal:)]; }




- (void) cp_set_solution:(ClueSolution const*)x
    {
    if (x == 0)
	cp_solution_ptr = 0;
    else
	{
	cp_solution_buff = *x;
	cp_solution_ptr = &cp_solution_buff;
	}
    }

- (void) cp_do_suggest:sender	{ [clueMgr suggest:cp_solution_ptr ok:self]; }
- (void) suggest:(ClueSolution const*)x
    {
    [self cp_set_solution:x];
    [self delayed:@selector(cp_do_suggest:)];
    }


- (void) cp_do_accuse:sender	{ [clueMgr accuse:cp_solution_ptr ok:self]; }
- (void) accuse:(ClueSolution const*)x
    {
    [self cp_set_solution:x];
    [self delayed:@selector(cp_do_accuse:)];
    }




//--------------------//
// SUBCLASS INTERFACE //	// Override these methods in your subclass.
//--------------------//
- (void) newLocation:(ClueCoord)pos		{ location = pos; }
- (void) player:(int)y accuses:(ClueSolution const*)x wins:(BOOL)b {}
- (void) player:(int)y cannotDisprove:(ClueSolution const*)x	{}
- (void) player:(int)y disproves:(ClueSolution const*)x		{}
- (void) nobodyDisproves:(ClueSolution const*)x			{}

- (void) makeMove				{ [self moveTo:location]; }
- (void) player:(int)y reveals:(ClueCard)x	{ [self revealOk]; }
- (void) makeSuggestion				{ [self suggest:0]; }
- (void) makeAccusation				{ [self accuse:0]; }

- (void) disprove:(ClueSolution const*)solution forPlayer:(int)playerID
    {
    int num_choices = 0;
    ClueCard choices[3];
    ClueCard card = CLUE_CARD_MAX;
    for (int i = 0; i < num_cards; i++)
	{
	ClueCard const x = cards[i];
	if (solution->contains( x ))
	    choices[ num_choices++ ] = x;
	}

    if (num_choices > 0)
	if (num_choices == 1)
	    card = choices[0];
	else
	    card = choices[ random_int(num_choices) ];

    [self reveal:card];
    }


- (void) nextPlayer:(int)x
    {
    BOOL const was_my_turn = my_turn;
    my_turn = (x == [self playerID]);

    if (was_my_turn && !my_turn)	// End of my turn.
	{
	last_room = ClueRoomAt( [self location] );
	can_stay = NO;
	}

    [self nextPlayerOk];
    }


- (void) player:(int)y suggests:(ClueSolution const*)p
    {
    if (!my_turn &&
	p->suspect() == [self pieceID] &&
	p->room() != last_room)
	{
	last_room = CLUE_CARD_MAX;
	can_stay = YES;
	}
    }

@end
