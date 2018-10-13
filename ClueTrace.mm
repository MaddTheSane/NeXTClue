//-----------------------------------------------------------------------------
// ClueTrace.M
//
//	This object manages a Text object, formatting and appending standard
//	Clue messages.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueTrace.M,v 1.1 97/05/31 10:13:04 zarnuk Exp Locker: zarnuk $
// $Log:	ClueTrace.M,v $
//  Revision 1.1  97/05/31  10:13:04  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueTrace.h"
#import	"ClueLoadNib.h"

extern "Objective-C" {
#import <appkit/Text.h>
#import <appkit/Cell.h>
}

extern "C" {
#import <stdio.h>
}


@implementation ClueTrace

//-----------------------------------------------------------------------------
// initText:
//-----------------------------------------------------------------------------
- initText:(Text*)obj
    {
    [super init];
    text = obj;
    return self;
    }


//-----------------------------------------------------------------------------
// appendText:
//-----------------------------------------------------------------------------
- (void) appendText:(char const*)s
    {
    int const n = [text charLength];
    [text setSel:n:n];
    [text replaceSel:s];
    }

- (void) appendIcon:(char const*)s
    {
    Cell* cell = [[Cell alloc] initIconCell:s];
    int const n = [text charLength];
    [text setSel:n:n];
    [text replaceSelWithCell:cell];
    }

- (void) appendPiece:(ClueCard)x
    {
    char const* const s = ClueCardName(x);
    [self appendText:" "];
    [self appendText:s];
    [self appendText:" "];
    [self appendIcon:s];
    [self appendText:"  "];
    }


- (void) fancyPlayer:(int)player action:(char const*)action
	solution:(ClueSolution const*)x
    {
    char buff[256];
    sprintf( buff, "player %d %s: ", player+1, action );
    [self appendText:buff];
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	[self appendPiece:x->v[i]];
    }

- (void) player:(int)playerID accuses:(ClueSolution const*)x wins:(BOOL)wins
    {
    [self fancyPlayer:playerID action:"accuses" solution:x];
    [self appendText:(wins ? "and wins.\n\n" : "and loses.\n\n")];
    [text scrollSelToVisible];
    }

- (void) player:(int)playerID suggests:(ClueSolution const*)x
    {
    [self fancyPlayer:playerID action:"suggests" solution:x];
    [self appendText:"\n"];
    }

- (char const*) format:(ClueSolution const*)x
    {
    static char buff[256];
    sprintf( buff, "%s %s %s",
	ClueCardName(x->suspect()),
	ClueCardName(x->weapon()),
	ClueCardName(x->room()) );
    return buff;
    }

- (void) message:(char const*)msg solution:(ClueSolution const*)x
    {
    char buff[256];
    sprintf( buff, "%s: %s\n", msg, [self format:x] );
    [self appendText:buff];
    }

- (void) player:(int)playerID action:(char const*)a
	solution:(ClueSolution const*)x
    {
    char buff[256];
    sprintf( buff, "player %d %s", playerID + 1, a );
    [self message:buff solution:x];
    }

- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)x
    {
    [self player:playerID action:"cannot disprove" solution:x];
    }

- (void) player:(int)playerID disproves:(ClueSolution const*)x
    {
    [self player:playerID action:"disproves" solution:x];
    [self appendText:"\n"];
    [text scrollSelToVisible];
    }


- (void) nobodyDisproves:(ClueSolution const*)x
    {
    [self message:"nobody disproves" solution:x];
    [self appendText:"\n"];
    [text scrollSelToVisible];
    }


- (void) player:(int)p reveals:(ClueCard)card
    {
    char buff[128];
    sprintf( buff, "player %d reveals ", p+1 );
    [self appendText:buff];
    [self appendPiece:card];
    [self appendText:"\n\n"];
    [text scrollSelToVisible];
    }


- (void) newGameNumPlayers:(int)n
    {
    char buff[128];
    sprintf( buff, "New game: %d players.\n", n );
    [self appendText:buff];
    }


- (void) player:(int)p piece:(ClueCard)c name:(char const*)s numCards:(int)n
    {
    char buff[128];
    sprintf( buff, "player %d: %s, %d cards, piece: ", p+1, s, n );
    [self appendText:buff];
    [self appendPiece:c];
    [self appendText:"\n"];
    }


- (void) player:(int)p num:(int)n cards:(ClueCard const*)cards
    {
    char buff[128];
    sprintf( buff, "\nplayer %d: hand: ", p+1 );
    [self appendText:buff];
    for (int i = 0; i < n; i++)
	[self appendPiece:cards[i]];
    [self appendText:"\n\n"];
    [text scrollSelToVisible];
    }

@end
