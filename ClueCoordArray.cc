//-----------------------------------------------------------------------------
// ClueCoordArray.cc
//
//	Dynamically sized list of Clue coordinates.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#ifdef __GNUC__
#pragma implementation
#endif
#include "ClueCoordArray.h"
extern "C" {
#include <assert.h>
#include <stdlib.h>	// malloc(), realloc(), free()
}

ClueCoordArray::ClueCoordArray():num_recs(0),max_recs(32)
    {
    recs = (ClueCoord*) malloc( max_recs * sizeof(*recs) );
    }


ClueCoordArray::~ClueCoordArray()
    {
    free( recs );
    }


void ClueCoordArray::expand()
    {
    max_recs += max_recs;
    recs = (ClueCoord*) realloc( recs, max_recs * sizeof(*recs) );
    }


void ClueCoordArray::append( ClueCoord const& r )
    {
    if (num_recs >= max_recs) expand();
    recs[ num_recs++ ] = r;
    }


ClueCoord ClueCoordArray::pop()
    {
    assert( !is_empty() );
    return recs[ --num_recs ];
    }
