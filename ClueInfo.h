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
// $Id: ClueInfo.h,v 1.2 97/05/31 14:06:16 zarnuk Exp Locker: zarnuk $
// $Log:	ClueInfo.h,v $
//  Revision 1.2  97/05/31  14:06:16  zarnuk
//  v21: Added buildField.
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <objc/Object.h>
}
@class TextField, Window;

@interface ClueInfo:Object
    {
    Window*	window;
    TextField*	buildField;
    TextField*	releaseField;
    }
+ launch;
@end

#endif // __ClueInfo_h
