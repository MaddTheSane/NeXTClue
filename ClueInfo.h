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
// $Id: ClueInfo.h,v 1.3 97/06/27 10:38:16 zarnuk Exp $
// $Log:	ClueInfo.h,v $
//  Revision 1.3  97/06/27  10:38:16  zarnuk
//  v23 -- Added releaseField.
//  
//  Revision 1.2  97/05/31  14:06:16  zarnuk
//  v21: Added buildField.
//-----------------------------------------------------------------------------

#import <Foundation/NSObject.h>

@class NSTextField, NSWindow;

@interface ClueInfo:NSObject
    {
    NSWindow*	window;
    NSTextField*	buildField;
    NSTextField*	releaseField;
    }
+ launch;
@end

#endif // __ClueInfo_h
