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

#import <Cocoa/Cocoa.h>

@interface ClueRules : NSObject
{
    IBOutlet NSTextView* text;
    IBOutlet NSWindow* window;
}
+ (void)launch;
@end

#endif // __ClueRules_h
