#ifndef __ClueSetup_h
#define __ClueSetup_h
//-----------------------------------------------------------------------------
// ClueSetup.h
//
//	User preferences module for the Clue game.
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

@class Button;
@class Window;

@interface ClueSetup:Object
    {
    Window*	window;
    Button*	mustardPop;
    Button*	plumPop;
    Button*	greenPop;
    Button*	peacockPop;
    Button*	scarletPop;
    Button*	whitePop;
    Button*	pops[ 6 ];
    }

+ (BOOL) startNewGame;
+ (int) numPlayers;
+ (ClueCard) playerPiece:(int)n;
+ (id) playerClass:(int)n;

@end

#endif // __ClueSetup_h
