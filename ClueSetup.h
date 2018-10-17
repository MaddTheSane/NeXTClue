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
// $Id: ClueSetup.h,v 1.1 97/05/31 10:12:40 zarnuk Exp $
// $Log:	ClueSetup.h,v $
//  Revision 1.1  97/05/31  10:12:40  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <Foundation/NSObject.h>
}
#import	"ClueDefs.h"

@class NSButton;
@class NSWindow;

@interface ClueSetup:NSObject
    {
    NSWindow*	window;
    NSButton*	mustardPop;
    NSButton*	plumPop;
    NSButton*	greenPop;
    NSButton*	peacockPop;
    NSButton*	scarletPop;
    NSButton*	whitePop;
    NSButton*	pops[ 6 ];
    }

+ (BOOL) startNewGame;
+ (int) numPlayers;
+ (ClueCard) playerPiece:(int)n;
+ (id) playerClass:(int)n;

@end

#endif // __ClueSetup_h
