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
// $Id: ClueCyBorg.h,v 1.1 97/05/31 10:10:34 zarnuk Exp $
// $Log:	ClueCyBorg.h,v $
//  Revision 1.1  97/05/31  10:10:34  zarnuk
//  v21
//  
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

- (void)dealloc;
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
