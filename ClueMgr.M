//-----------------------------------------------------------------------------
// ClueMgr.M
//
//	Game manager for the Clue app.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import	"ClueMgr.h"
#import	"ClueBoard.h"
#import	"ClueCoordArray.h"
#import	"ClueInfo.h"
#import	"CluePlayer.h"
#import	"ClueRules.h"
#import	"ClueSetup.h"
#import	"ClueMessages.h"
#import	"ClueTrace.h"
extern "Objective-C" {
#import <appkit/Application.h>
}
extern "C" {
#import	<assert.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <time.h>
}


//-----------------------------------------------------------------------------
// next_player
//-----------------------------------------------------------------------------
inline static int next_player( int i, int N )
    {
    if (++i >= N) i = 0;
    return i;
    }


//-----------------------------------------------------------------------------
// deck_swap
//-----------------------------------------------------------------------------
static void deck_swap( int i, int j, ClueCard* deck )
    {
    if (i != j)
	{
	ClueCard const t = deck[i];
	deck[i] = deck[j];
	deck[j] = t;
	}
    }


//-----------------------------------------------------------------------------
// sort_hand
//	Sort the cards in the player's hand into ascending order as a
//	convenience to the player.  This is a simple insertion sort.
//-----------------------------------------------------------------------------
static void sort_hand( int start_pos, int n, ClueCard* deck )
    {
    int const lim = start_pos + n;
    for (int i = start_pos + 1; i < lim; i++)
	{
	ClueCard const k = deck[i];
	int j = i;
	while (--j >= start_pos && deck[j] > k)
	    deck[j+1] = deck[j];
	deck[++j] = k;
	}
    }


@interface ClueMgr(ForwardReference)
- (void) startNextPlayer;
@end


@implementation ClueMgr

//-----------------------------------------------------------------------------
// boardView
//-----------------------------------------------------------------------------
- (ClueBoardView*) boardView
    {
    return [board boardView];
    }


//-----------------------------------------------------------------------------
// rollDie
//-----------------------------------------------------------------------------
- (int) rollDie
    {
    return random_int( 6 ) + 1;
    }


//-----------------------------------------------------------------------------
// delayed:
//-----------------------------------------------------------------------------
- (void) delayed:(SEL)aSel
    {
    [self perform:aSel with:0 afterDelay:0 cancelPrevious:NO];
    }


//=============================================================================
// LOCATIONS
//=============================================================================

//-----------------------------------------------------------------------------
// pieceLocation:
//-----------------------------------------------------------------------------
- (ClueCoord) pieceLocation:(ClueCard)piece
    {
    assert( piece < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT );
    return locations[ piece ];
    }


//-----------------------------------------------------------------------------
// pieceAt:
//-----------------------------------------------------------------------------
- (ClueCard) pieceAt:(ClueCoord)pos
    {
    for (unsigned int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	if (locations[i] == pos)
	    return ClueCard(i);
    return CLUE_CARD_MAX;
    }


//-----------------------------------------------------------------------------
// playerForPiece:
//-----------------------------------------------------------------------------
- (CluePlayer*) playerForPiece:(ClueCard)piece
    {
    for (int i = 0; i < num_players; i++)
	if (players[i].piece_id == piece)
	    return players[i].player;
    return 0;
    }


//-----------------------------------------------------------------------------
// movePiece:to:
//-----------------------------------------------------------------------------
- (BOOL) movePiece:(ClueCard)piece to:(ClueCoord)pos
    {
    assert( piece < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT );
    assert( ClueGoodCoord( pos ) );
    ClueCoord const old_pos = locations[ piece ];
    if (old_pos != pos)
	{
	locations[ piece ] = pos;
	if (piece < CLUE_SUSPECT_COUNT)
	    [[self playerForPiece:piece] newLocation:pos];
	[board movePiece:piece from:old_pos to:pos];
	}
    return YES;
    }


//-----------------------------------------------------------------------------
// roomCoord:
//-----------------------------------------------------------------------------
- (ClueCoord) roomCoord:(ClueCard)room
    {
    ClueCoord pos;
    do { pos = ClueRoomCoord( room ); }
    while ([self pieceAt:pos] != CLUE_CARD_MAX);
    return pos;
    }


//=============================================================================
// BROADCAST
//=============================================================================

- (void) player:(int)playerID accuses:(ClueSolution const*)buff wins:(BOOL)wins
    {
    [trace player:playerID accuses:buff wins:wins];
    for (int i = 0; i < num_players; i++)
	[players[i].player player:playerID accuses:buff wins:wins];
    }


- (void) player:(int)playerID suggests:(ClueSolution const*)buff
    {
    [trace player:playerID suggests:buff];
    for (int i = 0; i < num_players; i++)
	[players[i].player player:playerID suggests:buff];
    }


- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)buff;
    {
    [trace player:playerID cannotDisprove:buff];
    for (int i = 0; i < num_players; i++)
	[players[i].player player:playerID cannotDisprove:buff];
    }


- (void) player:(int)playerID disproves:(ClueSolution const*)buff;
    {
    [trace player:playerID disproves:buff];
    for (int i = 0; i < num_players; i++)
	[players[i].player player:playerID disproves:buff];
    }


- (void) nobodyDisproves:(ClueSolution const*)buff;
    {
    [trace nobodyDisproves:buff];
    for (int i = 0; i < num_players; i++)
	[players[i].player nobodyDisproves:buff];
    }



//=============================================================================
// PLAY
//=============================================================================

//-----------------------------------------------------------------------------
// accuse:ok:
//
// NOTE *1*
//	If a player loses, we must move that player's piece out of the 
//	corridors to make sure that it does not block the movement of other 
//	players.  
//-----------------------------------------------------------------------------
- (void) accuse:(ClueSolution const*)x ok:(CluePlayer*)p
    {
    assert( p == waiting_for );
    assert( state == CLUE_STATE_ACCUSE );
    if (x != 0)
	{
	suggestion = *x;
	BOOL const wins = (suggestion == solution);
	[self player:player_id accuses:&suggestion wins:wins];
	stillPlaying = NO;
	if (!wins)
	    {
	    players[ player_id ].lost = YES;
	    ClueCard const piece_id = players[ player_id ].piece_id;
	    [self movePiece:piece_id to:CLUE_START_POS[ piece_id ]];	// *1*
	    for (int j = 0; j < num_players; j++)
		if (!players[j].lost && [players[j].player canSuggest])
		    {
		    stillPlaying = YES;
		    break;
		    }
	    }
	}
    if (stillPlaying)
	[self startNextPlayer];
    }


//-----------------------------------------------------------------------------
// startAccuse
//-----------------------------------------------------------------------------
- (void) startAccuse
    {
    state = CLUE_STATE_ACCUSE;
    query_id = player_id;
    waiting_for = players[query_id].player;
    [waiting_for makeAccusation];
    // Return to appkit event loop.
    // Expect player to respond via -accuse:ok:
    }


//-----------------------------------------------------------------------------
// revealOk:
//-----------------------------------------------------------------------------
- (void) revealOk:(CluePlayer*)p
    {
    assert( p == waiting_for );
    assert( state == CLUE_STATE_REVEAL_OK );
    [self startAccuse];
    }


//-----------------------------------------------------------------------------
// reveal:ok:
//-----------------------------------------------------------------------------
- (void) reveal:(ClueCard)card ok:(CluePlayer*)p
    {
    assert( p == waiting_for );
    assert( state == CLUE_STATE_REVEAL );
    assert( suggestion.contains( card ) );

    if ([players[player_id].player isHuman])
	[trace player:query_id reveals:card];

    state = CLUE_STATE_REVEAL_OK;
    int const revealing_id = query_id;
    query_id = player_id;
    waiting_for = players[query_id].player;
    [waiting_for player:revealing_id reveals:card];
    // Return to appkit event loop.
    // Expect player to respond via -revealOk:
    }


//-----------------------------------------------------------------------------
// startReveal:
//-----------------------------------------------------------------------------
- (void) startReveal:(int)i :(ClueSolution const*)x
    {
    state = CLUE_STATE_REVEAL;
    query_id = i;
    waiting_for = players[query_id].player;
    [waiting_for disprove:x forPlayer:player_id];
    // Return to appkit event loop.
    // Expect player to respond via -reveal:ok:
    }


//-----------------------------------------------------------------------------
// player:canDisprove:
//-----------------------------------------------------------------------------
- (BOOL) player:(int)i canDisprove:(ClueSolution const*)x
    {
    CluePlayerRec const& r = players[i];
    ClueCard const* p = deck + r.hand_start;
    ClueCard const* plim = p + r.hand_length;
    while (p < plim)
	if (x->contains( *p++ ))
	    return YES;
    return NO;
    }


//-----------------------------------------------------------------------------
// suggest:ok:
//-----------------------------------------------------------------------------
- (void) suggest:(ClueSolution const*)x ok:(CluePlayer*)p
    {
    assert( p == waiting_for );
    assert( state == CLUE_STATE_SUGGEST );
    if (x == 0)
	[self startAccuse];
    else
	{
	suggestion = *x;
	[self player:player_id suggests:&suggestion];	// broadcast.

	ClueCard const room = suggestion.room();
	ClueCard const suspect = suggestion.suspect();
	if (ClueRoomAt( [self pieceLocation:suspect] ) != room)
	    [self movePiece:suspect to:[self roomCoord:room]];

	ClueCard const weapon = suggestion.weapon();
	if (ClueRoomAt( [self pieceLocation:weapon] ) != room)
	    [self movePiece:weapon to:[self roomCoord:room]];

	int j = player_id;
	j = next_player( j, num_players );
	while (j != player_id && ![self player:j canDisprove:&suggestion])
	    {
	    [self player:j cannotDisprove:&suggestion];	// broadcast
	    j = next_player( j, num_players );
	    }

	if (j == player_id)
	    {
	    [self nobodyDisproves:&suggestion];		// broadcast
	    [self startAccuse];
	    }
	else
	    {
	    [self player:j disproves:&suggestion];	// broadcast
	    [self startReveal:j:&suggestion];
	    }
	}
    }


//-----------------------------------------------------------------------------
// startSuggest
//-----------------------------------------------------------------------------
- (void) startSuggest
    {
    state = CLUE_STATE_SUGGEST;
    query_id = player_id;
    waiting_for = players[ query_id ].player;
    [waiting_for makeSuggestion];
    // Return to appkit event loop.
    // Expect player to respond via -suggest:ok:
    }


//-----------------------------------------------------------------------------
// moveTo:ok:
//-----------------------------------------------------------------------------
- (void) moveTo:(ClueCoord)coord ok:(CluePlayer*)p
    {
    assert( p == waiting_for );
    assert( state == CLUE_STATE_MOVE );
    // FIXME: Check for legal move.
    [self movePiece:players[player_id].piece_id to:coord];
    // FIXME: Only start suggest if the player is in a room where they can
    // make a suggestion from.
    [self startSuggest];
    }


//-----------------------------------------------------------------------------
// startMove
//-----------------------------------------------------------------------------
- (void) startMove
    {
    state = CLUE_STATE_MOVE;
    query_id = player_id;
    waiting_for = players[ query_id ].player;
    [waiting_for makeMove];
    // Return to appkit event loop.
    // Expect player to respond via -moveTo:ok:
    }


//-----------------------------------------------------------------------------
// sendNextPlayer
//-----------------------------------------------------------------------------
- (void) sendNextPlayer
    {
    query_id = next_player( query_id, num_players );
    waiting_for = players[ query_id ].player;
    [waiting_for nextPlayer:player_id];
    // Return to appkit event loop.
    // Expect player to respond via -nextPlayerOk:
    }


//-----------------------------------------------------------------------------
// nextPlayerOk:
//-----------------------------------------------------------------------------
- (void) nextPlayerOk:(CluePlayer*)p
    {
    assert( p == waiting_for );
    assert( state == CLUE_STATE_NEXT_PLAYER );
    if (query_id != player_id)
	[self sendNextPlayer];
    else
	[self startMove];
    }


//-----------------------------------------------------------------------------
// startNextPlayer
//-----------------------------------------------------------------------------
- (void) startNextPlayer
    {
    state = CLUE_STATE_NEXT_PLAYER;
    int start_id = player_id;
    do  {
	player_id = next_player( player_id, num_players );
	assert( player_id != start_id );	// FIXME? crashes here.
	}
    while (players[player_id].lost || ![players[player_id].player canSuggest]);
    query_id = player_id;
    [self sendNextPlayer];
    }


//=============================================================================
// NEW GAME
//=============================================================================
//-----------------------------------------------------------------------------
// abortGame
//-----------------------------------------------------------------------------
- (void) abortGame
    {
    for (int i = 0; i < CLUE_NUM_PLAYERS_MAX; i++)
	{
	[players[i].player free];
	players[i].player = 0;
	}
    [messages free];
    messages = 0;
    trace = 0;
    [board free];
    board = 0;
    }


//-----------------------------------------------------------------------------
// initDeckAndSolution
//-----------------------------------------------------------------------------
- (void) initDeckAndSolution
    {
    // Initialize the deck.
    for (unsigned int c = 0; c <= (unsigned int) CLUE_CARD_COUNT; c++)
	deck[c] = ClueCard( c + (unsigned int) CLUE_CARD_FIRST );

    // Choose the solution.
    unsigned int const N =
	CLUE_SUSPECT_COUNT * CLUE_WEAPON_COUNT * CLUE_ROOM_COUNT;
    unsigned int n = random_int( N );
    unsigned int const weapon = n % CLUE_WEAPON_COUNT;	n /= CLUE_WEAPON_COUNT;
    unsigned int const room = n % CLUE_ROOM_COUNT;	n /= CLUE_ROOM_COUNT;
    unsigned int const suspect = n;

    solution.suspect() = ClueCard( int(CLUE_SUSPECT_FIRST) + suspect );
    solution.weapon()  = ClueCard( int(CLUE_WEAPON_FIRST) + weapon );
    solution.room()    = ClueCard( int(CLUE_ROOM_FIRST) + room );

    // Select the solution cards.
    unsigned int deck_top = CLUE_CARD_COUNT;
    deck_swap( int(CLUE_ROOM_FIRST) + room, --deck_top, deck );
    deck_swap( int(CLUE_WEAPON_FIRST) + weapon, --deck_top, deck );
    deck_swap( int(CLUE_SUSPECT_FIRST) + suspect, --deck_top, deck );

    // Shuffle the remaining cards.
    while (deck_top > 1)
	{
	deck_swap( random_int( deck_top ), deck_top - 1, deck );
	deck_top--;
	}
    }


//-----------------------------------------------------------------------------
// initPlayers
//-----------------------------------------------------------------------------
- (void) initPlayers
    {
    num_players = [ClueSetup numPlayers];

    int const NUM_CARDS = CLUE_CARD_COUNT - CLUE_CATEGORY_COUNT;
    int hand_length = NUM_CARDS / num_players;
    int nextras = NUM_CARDS % num_players;
    int deck_pos = 0;
    for (int i = 0; i < num_players; i++)
	{
	CluePlayerRec& r = players[i];
	r.player_id = i;
	r.piece_id = [ClueSetup playerPiece:i];
	int ncards = hand_length;
	if (nextras-- > 0)
	    ncards++;
	r.hand_start = deck_pos;
	r.hand_length = ncards;
	sort_hand( deck_pos, ncards, deck );
	deck_pos += ncards;
	r.player = 0;
	r.lost = NO;
	r.player = [[[ClueSetup playerClass:i] alloc]
		initPlayer:i numPlayers:num_players
		numCards:r.hand_length cards:deck + r.hand_start
		piece:r.piece_id location:locations[r.piece_id] clueMgr:self];
	}
    }


//-----------------------------------------------------------------------------
// initPieces
//-----------------------------------------------------------------------------
- (void) initPieces
    {
    for (int i = 0; i < CLUE_SUSPECT_COUNT; i++)
	locations[i] = CLUE_START_POS[i];

    // For now places the weapons in the 'stair well'; later randomize them.
    for (int r = 10, j = CLUE_CARD_KNIFE; r < 16; r += 2)
	for (int c = 11; c < 15; c += 2, j++)	// FIXME: Hardcoded, bleh!
	    { locations[j].row = r; locations[j].col = c; }
    }


//-----------------------------------------------------------------------------
// launchBoard
//-----------------------------------------------------------------------------
- (void) launchBoard
    {
    if (board == 0)
	board = [[ClueBoard allocFromZone:[self zone]] initWithMgr:self];
    [board orderFront];
    }


//-----------------------------------------------------------------------------
// startupMessages
//-----------------------------------------------------------------------------
- (void) startupMessages
    {
    int i;

    [trace newGameNumPlayers: num_players];

    for (i = 0; i < num_players; i++)
	{
	CluePlayerRec const& r = players[i];
	char const* const s = [r.player playerName];
	[trace player:i piece:r.piece_id name:s numCards:r.hand_length];
	}

    for (i = 0; i < num_players; i++)
	{
	CluePlayerRec const& r = players[i];
	if ([r.player isHuman])
	    [trace player:i num:r.hand_length cards: deck + r.hand_start];
	}
    }


//-----------------------------------------------------------------------------
// launchMessages:
//-----------------------------------------------------------------------------
- launchMessages:sender
    {
    if (messages == 0)
	{
	messages = [[ClueMessages alloc] init];
	trace = [messages getTrace];
	}
    [messages orderFront:self];
    return self;
    }


//-----------------------------------------------------------------------------
// startNewGame:
//-----------------------------------------------------------------------------
- (void) startNewGame:sender
    {
    [self launchMessages:self];
    [self initDeckAndSolution];
    [self initPieces];
    [self initPlayers];
    [self launchBoard];
    [self startupMessages];

    stillPlaying = YES;
    player_id = -1;
    [self startNextPlayer];
    }


//-----------------------------------------------------------------------------
// doNewGame:
//-----------------------------------------------------------------------------
- (void) doNewGame:sender
    {
    if ([ClueSetup startNewGame])
	{
	[self abortGame];
	state = CLUE_STATE_NEW_GAME;
	[self delayed:@selector(startNewGame:)];
	}
    }


//-----------------------------------------------------------------------------
// newGame:
//-----------------------------------------------------------------------------
- newGame:sender
    {
    // Need to let the Menu close before starting the modal new game panel.
    [self delayed:@selector(doNewGame:)];
    return self;
    }


//-----------------------------------------------------------------------------
// appInfo:
//-----------------------------------------------------------------------------
- appInfo:sender
    {
    [ClueInfo launch];
    return self;
    }


//-----------------------------------------------------------------------------
// showRules:
//-----------------------------------------------------------------------------
- showRules:sender
    {
    [ClueRules launch];
    return self;
    }


//-----------------------------------------------------------------------------
// +initialize
//-----------------------------------------------------------------------------
+ initialize
    {
    SRANDOM( time(0) );
    CLUE_CARD_PBTYPE = NXUniqueString( "ClueCard(tm)" );
    return self;
    }

@end
