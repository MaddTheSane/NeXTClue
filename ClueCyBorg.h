#ifndef __ClueCyBorg_h
#define __ClueCyBorg_h
//-----------------------------------------------------------------------------
// ClueCyBorg.h
//
//	Computer player that goes beyond mere logic.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueDeeDucer.h"

class ClueHistory;

@interface ClueCyBorg : ClueDeeDucer
	{
	float probs[ CLUE_NUM_PLAYERS_MAX + 1 ][ CLUE_CARD_COUNT ];
	BOOL nailed[ CLUE_CARD_COUNT ];
	ClueHistory* history;
	BOOL did_init;
	}

- free;
- (void) earlyInit;
- (void) lateInit;

- (void) stack:(ClueUpdateStack*)stack player:(int)p holdsCard:(ClueCard)c;
- (void) stack:(ClueUpdateStack*)stack player:(int)p notHoldsCard:(ClueCard)c;
- (void) player:(int)playerID suggests:(ClueSolution const*)buff;
- (void) player:(int)playerID disproves:(ClueSolution const*)buff;
- (void) nobodyDisproves:(ClueSolution const*)buff;

- (int) scoreUnknown:(int)card;
@end

#endif // __ClueCyBorg_h
