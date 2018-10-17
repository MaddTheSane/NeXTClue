#ifndef __ClueCyLent_h
#define __ClueCyLent_h
//-----------------------------------------------------------------------------
// ClueCyLent.h
//
//	Computer player that makes neither suggestions, nor accusations.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueCyLent.h,v 1.1 97/05/31 10:10:15 zarnuk Exp $
// $Log:	ClueCyLent.h,v $
//  Revision 1.1  97/05/31  10:10:15  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueComputer.h"

@interface ClueCyLent : ClueComputer
- (BOOL) canAccuse;
- (BOOL) canSuggest;
@end

#endif // __ClueCyLent_h
