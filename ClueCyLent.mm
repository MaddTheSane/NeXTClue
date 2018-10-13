//-----------------------------------------------------------------------------
// ClueCyLent.M
//
//	Computer player that makes neither suggestions, nor accusations.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueCyLent.h"

@implementation ClueCyLent
- (char const*) playerName	{ return "Cy Lent"; }
- (BOOL) canAccuse		{ return NO; }
- (BOOL) canSuggest		{ return NO; }
@end
