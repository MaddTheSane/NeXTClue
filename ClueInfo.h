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
// $Id: ClueInfo.h,v 1.1 97/05/31 10:10:50 zarnuk Exp Locker: zarnuk $
// $Log:	ClueInfo.h,v $
//  Revision 1.1  97/05/31  10:10:50  zarnuk
//  v21
//-----------------------------------------------------------------------------
extern "Objective-C" {
#import <objc/Object.h>
}
@class TextField, Window;

@interface ClueInfo:Object
    {
    Window*	window;
    TextField*	versionField;
    }
+ launch;
@end

#endif // __ClueInfo_h
