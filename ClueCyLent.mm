//-----------------------------------------------------------------------------
// ClueCyLent.M
//
//	Computer player that makes neither suggestions, nor accusations.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueCyLent.M,v 1.1 97/05/31 10:10:12 zarnuk Exp $
// $Log:	ClueCyLent.M,v $
//  Revision 1.1  97/05/31  10:10:12  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueCyLent.h"

@implementation ClueCyLent
- (NSString*) playerName	{ return @"Cy Lent"; }
- (BOOL) canAccuse		{ return NO; }
- (BOOL) canSuggest		{ return NO; }
@end
