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
// $Id$
// $Log$
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <objc/Object.h>
}
@class Text, Window;

@interface ClueRules : Object
    {
    Text* text;
    Window* window;
    }
+ (void)launch;
@end

#endif // __ClueRules_h
