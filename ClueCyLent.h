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
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueComputer.h"

@interface ClueCyLent : ClueComputer
- (BOOL) canAccuse;
- (BOOL) canSuggest;
@end

#endif // __ClueCyLent_h
