#ifndef __ClueInfo_h
#define __ClueInfo_h
//-----------------------------------------------------------------------------
// ClueInfo.h
//
//	Info panel for the Clue program.
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
@class Window;

@interface ClueInfo:Object
    {
    Window*	window;
    }
+ launch;
@end

#endif // __ClueInfo_h
