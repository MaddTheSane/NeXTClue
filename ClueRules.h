#ifndef __ClueRules_h
#define __ClueRules_h
//-----------------------------------------------------------------------------
// ClueRules.h
//
//	Window with scrollable text to display the rules of the game.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueRules.h,v 1.1 97/05/31 10:11:58 zarnuk Exp $
// $Log:	ClueRules.h,v $
//  Revision 1.1  97/05/31  10:11:58  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------

#import <Foundation/NSObject.h>
@class NSText, NSWindow;

@interface ClueRules : NSObject
    {
    NSText* text;
    NSWindow* window;
    }
+ (void)launch;
@end

#endif // __ClueRules_h
