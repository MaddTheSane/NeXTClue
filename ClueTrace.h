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
// $Id: ClueTrace.h,v 1.1 97/05/31 10:13:05 zarnuk Exp $
// $Log:	ClueTrace.h,v $
//  Revision 1.1  97/05/31  10:13:05  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import	"ClueDefs.h"

@interface ClueTrace : NSObject
{
    NSText*	text;
}

- (instancetype)initWithText:(NSText*)text;
- (void) appendText:(NSString*)s;
- (void) appendIcon:(NSString*)s;
- (void) appendPiece:(ClueCard)x;
- (void) newGameNumPlayers:(int)n;
- (void) player:(int)p piece:(ClueCard)c name:(NSString*)s numCards:(int)n;
- (void) player:(int)p num:(int)n cards:(ClueCard const*)cards;
- (void) player:(int)playerID accuses:(ClueSolution const*)buff wins:(BOOL)wins;
- (void) player:(int)playerID suggests:(ClueSolution const*)buff;
- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)buff;
- (void) player:(int)playerID disproves:(ClueSolution const*)buff;
- (void) nobodyDisproves:(ClueSolution const*)buff;
- (void) player:(int)playerID reveals:(ClueCard)card;

@end

#endif // __ClueTrace_h
