#ifndef __ClueButton_h
#define __ClueButton_h
//-----------------------------------------------------------------------------
// ClueButton.h
//
//	Category for the Button class which provides tag-oriented access
//	to popup lists.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import	<appkit/Button.h>
}

@interface Button(Pop)
- (void) selectTag:(int)x;
- (int) selectedTag;
@end

#endif // __ClueButton_h
