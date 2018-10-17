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
// $Id: ClueMessages.h,v 1.1 97/05/31 10:11:06 zarnuk Exp $
// $Log:	ClueMessages.h,v $
//  Revision 1.1  97/05/31  10:11:06  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <Foundation/NSObject.h>
}
#import	"ClueDefs.h"

@class ClueTrace;
@class NSText,NSPanel;

@interface ClueMessages:NSObject
    {
    NSPanel*	window;
    NSText*	text;
    ClueTrace*	trace;
    }
- init;
- (void)orderFront:(id)sender;
- (ClueTrace*) getTrace;
@end

#endif // __ClueMessages_h
