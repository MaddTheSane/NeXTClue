#ifndef __ClueMessages_h
#define __ClueMessages_h
//-----------------------------------------------------------------------------
// ClueMessages.h
//
//	This object manages a Text object, formatting and appending standard
//	Clue messages.
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

@class ClueTrace;
@class Text,Panel;

@interface ClueMessages:Object
    {
    Panel*	window;
    Text*	text;
    ClueTrace*	trace;
    }
- init;
- orderFront:sender;
- (ClueTrace*) getTrace;
@end

#endif // __ClueMessages_h
