#ifndef __ClueTrace_h
#define __ClueTrace_h
//-----------------------------------------------------------------------------
// ClueTrace.h
//
//	This object manages a Text object, formatting and appending standard
//	Clue messages.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <objc/Object.h>
}
#import	"ClueDefs.h"

@class Text;

@interface ClueTrace : Object
    {
    Text*	text;
    }

- initText:(Text*)text;
- (void) appendText:(char const*)s;
- (void) appendIcon:(char const*)s;
- (void) appendPiece:(ClueCard)x;
- (void) newGameNumPlayers:(int)n;
- (void) player:(int)p piece:(ClueCard)c name:(char const*)s numCards:(int)n;
- (void) player:(int)p num:(int)n cards:(ClueCard const*)cards;
- (void) player:(int)playerID accuses:(ClueSolution const*)buff wins:(BOOL)wins;
- (void) player:(int)playerID suggests:(ClueSolution const*)buff;
- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)buff;
- (void) player:(int)playerID disproves:(ClueSolution const*)buff;
- (void) nobodyDisproves:(ClueSolution const*)buff;
- (void) player:(int)playerID reveals:(ClueCard)card;

@end

#endif // __ClueTrace_h