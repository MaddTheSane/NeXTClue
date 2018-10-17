#ifndef __ClueCoordArray_h
#define __ClueCoordArray_h
#ifdef __GNUC__
#pragma interface
#endif
//-----------------------------------------------------------------------------
// ClueCoordArray.h
//
//	Dynamically sized list of Clue coordinates.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueCoordArray.h,v 1.1 97/05/31 10:09:24 zarnuk Exp $
// $Log:	ClueCoordArray.h,v $
//  Revision 1.1  97/05/31  10:09:24  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#include "ClueDefs.h"

class ClueCoordArray
	{
private:
	int num_recs;
	int max_recs;
	ClueCoord* recs;
	void expand();

public:
	ClueCoordArray();
	~ClueCoordArray();
	int count() const { return num_recs; }
	bool is_empty() const { return num_recs == 0; }
	void empty() { num_recs = 0; }
	void append( ClueCoord const& );
	void push( ClueCoord const& r ) { append(r); }
	ClueCoord pop();
	ClueCoord const& operator[]( int n ) const { return recs[n]; }
	};

#endif // __ClueCoordArray_h
