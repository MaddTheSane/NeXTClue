#ifndef __ClueDeeDucer_h
#define __ClueDeeDucer_h
//-----------------------------------------------------------------------------
// ClueDeeDucer.h
//
//	Clue computer player that analyzes revelations.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueDeeDucer.h,v 1.1 97/05/31 10:10:06 zarnuk Exp $
// $Log:	ClueDeeDucer.h,v $
//  Revision 1.1  97/05/31  10:10:06  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueAnnaLyzer.h"

class ClueCondArray;		// Array of conditional expressions.

@interface ClueDeeDucer : ClueAnnaLyzer
{
	ClueCondArray* cond_array;
}

- (void)dealloc;
- (void) earlyInit;
- (void) dump;
- (void) stack:(ClueUpdateStack*)stack player:(int)p holdsCard:(ClueCard)c;
- (void) stack:(ClueUpdateStack*)stack player:(int)p notHoldsCard:(ClueCard)c;

- (int) scoreUnknown:(int)card;
- (void) player:(int)p disproves:(ClueSolution const*)s;

@end

#endif // __ClueDeeDucer_h
