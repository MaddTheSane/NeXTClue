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

#import <Foundation/NSObject.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSButton.h>
#import	"ClueDefs.h"

@interface ClueSetup:NSObject
{
    IBOutlet NSWindow*	window;
    IBOutlet NSButton*	mustardPop;
    IBOutlet NSButton*	plumPop;
    IBOutlet NSButton*	greenPop;
    IBOutlet NSButton*	peacockPop;
    IBOutlet NSButton*	scarletPop;
    IBOutlet NSButton*	whitePop;
    NSButton*	pops[ 6 ];
}

+ (BOOL) startNewGame;
+ (int) numPlayers;
+ (ClueCard) playerPiece:(int)n;
+ (id) playerClass:(int)n;

@end

#endif // __ClueSetup_h
