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
// $Id: ClueButton.h,v 1.1 97/05/31 10:07:25 zarnuk Exp $
// $Log:	ClueButton.h,v $
//  Revision 1.1  97/05/31  10:07:25  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------

#import	<AppKit/NSButton.h>

@interface NSButton(Pop)
- (void) selectTag:(int)x;
- (int) selectedTag;
@end

#endif // __ClueButton_h
