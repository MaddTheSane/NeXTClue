//-----------------------------------------------------------------------------
// ClueHuman.M
//
//	Human player UI for the Clue app.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueHuman.h"
#import	"ClueBoardView.h"
#import	"ClueButton.h"
#import	"ClueCoordArray.h"
#import	"ClueLoadNib.h"
#import	"ClueMap.h"
#import	"ClueMgr.h"

#import	<MCGHTableScroll.h>
#import	<MCGHTableCell.h>

extern "Objective-C" {
#import	<appkit/Application.h>
#import	<appkit/Button.h>
#import	<appkit/ButtonCell.h>
#import	<appkit/Matrix.h>
#import	<appkit/NXImage.h>
#import <appkit/Text.h>
#import	<appkit/TextField.h>
#import	<appkit/Window.h>
}

extern "C" {
#import	<assert.h>
#import	<stdio.h>
#import	<string.h>
}

enum	{
	ICON_SLOT,
	NAME_SLOT,
	P1_SLOT,
	P2_SLOT,
	P3_SLOT,
	P4_SLOT,
	P5_SLOT,
	P6_SLOT,
	NOTES_SLOT,
	MAX_SLOT
	};

static char const* const DIE_ICON[] =
	{
	"die1",
	"die2",
	"die3",
	"die4",
	"die5",
	"die6"
	};

char const MAKE_ACCUSATION[] = "Make an accusation or skip.";

@interface ClueHuman(ForwardReference)
- (void) startAccuse;
@end

static BOOL VERTICAL_MOVEMENT = NO;

//-----------------------------------------------------------------------------
// ClueFilter
//-----------------------------------------------------------------------------
static unsigned short
ClueFilter( unsigned short c, int flags, unsigned short cset )
    {
    enum { KEY_UP = 0xad, KEY_DOWN = 0xaf };
    int const BAD = (NX_CONTROLMASK | NX_ALTERNATEMASK | NX_COMMANDMASK);
    if ((flags & BAD) == 0 && cset == NX_SYMBOLSET)
	{
	if (c == KEY_UP)
	    {
	    VERTICAL_MOVEMENT = YES;
	    return NX_BACKTAB;
	    }
	else if (c == KEY_DOWN)
	    {
	    VERTICAL_MOVEMENT = YES;
	    return NX_TAB;
	    }
	}
    VERTICAL_MOVEMENT = NO;
    return NXFieldFilter( c, flags, cset );
    }


//=============================================================================
// IMPLEMENTATION
//=============================================================================
@implementation ClueHuman

- (BOOL) isHuman		{ return YES; }
- (char const*) playerName	{ return "Human"; }

- (id) print:(id)x	{ [window smartPrintPSCode:self]; return self; }

//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- free
    {
    delete map;
    [scroll abortEditing];
    [fieldEditor free];
    [window close];
    [window free];
    return [super free];
    }


//-----------------------------------------------------------------------------
// separatorRow:tag:name:
//-----------------------------------------------------------------------------
- (void) separatorRow:(int)row tag:(int)tag name:(char const*)name
    {
    MCGHTableCell* cell;
    cell = [scroll cellAt:row:ICON_SLOT];
    [cell setTag:tag];
    cell = [scroll cellAt:row:NAME_SLOT];
    [cell setTag:tag];
    [cell setStringValue:name];

    for (int i = MAX_SLOT; i-- > 0; )
	{
	cell = [scroll cellAt:row:i];
	[cell setHighlightBackgroundColor:NX_COLORDKGRAY];
	[cell setBackgroundColor:NX_COLORDKGRAY];
	[cell setTextColor:NX_COLORWHITE];
	}
    }


//-----------------------------------------------------------------------------
// initScroll
//-----------------------------------------------------------------------------
- (void) initScroll
    {
    int i;
    for (i = P1_SLOT; i <= NOTES_SLOT; i++)
	{
	id proto = [scroll colCellPrototype:i];
	[proto setEditable:YES];
	[proto setScrollable:YES];
	}

    int const self_slot = int(P1_SLOT) + [self playerID];

    ClueCategory last_cat = ClueCategory(-1);
    [scroll renewRows:CLUE_CARD_COUNT + CLUE_CATEGORY_COUNT + 1];
    int row = 0;
    for (i = 0; i < CLUE_CARD_COUNT; i++,row++)
	{
	int const tag = ((i << 1) | 1);
	ClueCard const card = ClueCard(i);
	ClueCategory const cat = ClueCardCategory(card);
	MCGHTableCell* cell;

	if (last_cat != cat)
	    {
	    last_cat = cat;
	    int const x = (tag & ~1);	// Mask off low bit.
	    [self separatorRow:row++ tag:x name:ClueCategoryName(cat)];
	    }

	cell = [scroll cellAt:row:ICON_SLOT];
	[cell setIcon:ClueCardName(card)];
	[cell setTag:tag];

	cell = [scroll cellAt:row:NAME_SLOT];
	[cell setStringValueNoCopy:ClueCardName(card)];
	[cell setTag:tag];

	char const* const s = ([self amHoldingCard:card] ? "x" : "-");
	[[scroll cellAt:row:self_slot] setStringValueNoCopy:s];
	}

    [self separatorRow:row tag:(CLUE_CARD_COUNT << 1) name:"notes"];

    [scroll sortRows];
    }


//-----------------------------------------------------------------------------
// initPlayer:numPlayers:numCards:cards:piece:location:
//-----------------------------------------------------------------------------
- initPlayer:(int)playerID numPlayers:(int)numPlayers
	numCards:(int)numCards cards:(ClueCard const*)i_cards
	piece:(ClueCard)pieceID location:(ClueCoord)i_location
	clueMgr:(ClueMgr*)mgr
    {
    [super initPlayer:playerID numPlayers:numPlayers
	numCards:numCards cards:i_cards piece:pieceID
	location:i_location clueMgr:mgr];

    ClueLoadNib( self );
    fieldEditor = [[Text allocFromZone:[self zone]] init];
    [fieldEditor setCharFilter:ClueFilter];

    [suspectPop selectTag: [self pieceID]];
    [weaponPop selectTag: CLUE_CARD_KNIFE];
    [roomPop selectTag: CLUE_CARD_HALL];

    map = new ClueMap;

    [window setFrameAutosaveName:"ClueHumanWindow"];

    char buff[ 128 ];
    char const* const piece_name = ClueCardName( pieceID );
    sprintf( buff, "Player %d -- %s", playerID + 1, piece_name );
    [window setTitle:buff];

    [self initScroll];

    [messageField setStringValueNoCopy:"New Game"];

    [window makeKeyAndOrderFront:self];

    return self;
    }


//-----------------------------------------------------------------------------
// tableScroll:canEdit:at::
//-----------------------------------------------------------------------------
-  (BOOL)tableScroll:(MCGHTableScroll*)ts
    canEdit:(NXEvent const*)event at:(int)row :(int)col
    {
    return (col >= P1_SLOT);	// Edit on single-click allowed.
    }


//-----------------------------------------------------------------------------
// windowWillReturnFieldEditor:toObject:
//-----------------------------------------------------------------------------
- (id)windowWillReturnFieldEditor:(id)sender toObject:(id)client
    {
    return (client == scroll ? fieldEditor : 0);
    }


//-----------------------------------------------------------------------------
// editNext:row:col:
//-----------------------------------------------------------------------------
- (void)editNext:(BOOL)next row:(MCGHCoord_P)p_row col:(MCGHCoord_P)p_col
    {
    int const nrows = [scroll numRows];
    MCGHCoord_V v_row = [scroll rowPosition:p_row];

    v_row += (next ? 1 : -1);
    if (v_row >= nrows) v_row = 0;
    else if (v_row < 0) v_row = nrows - 1;

    p_row = [scroll rowAtPosition:v_row];
    if ([scroll canEdit:0 at:p_row:p_col])
	[scroll editCellAt:p_row:p_col];
    }


//-----------------------------------------------------------------------------
// textDidEnd:endChar:
//-----------------------------------------------------------------------------
- (id)textDidEnd:(id)sender endChar:(unsigned short)whyEnd
    {
    MCGHCoord_P row = [scroll clickedRow];
    MCGHCoord_P col = [scroll clickedCol];
    switch (whyEnd)
	{
	case NX_TAB:
	    if (VERTICAL_MOVEMENT)
		[self editNext:YES row:row col:col];
	    else if ([scroll getNext:YES editRow:&row andCol:&col])
		[scroll editCellAt:row:col];
	    break;
	case NX_BACKTAB:
	    if (VERTICAL_MOVEMENT)
		[self editNext:NO row:row col:col];
	    else if ([scroll getNext:NO editRow:&row andCol:&col])
		[scroll editCellAt:row:col];
	    break;
	}
    }


//-----------------------------------------------------------------------------
// allowDrag
//-----------------------------------------------------------------------------
- (void) allowDrag
    {
    [[clueMgr boardView] allowDrag:draggable map:map for:self];
    }


//=============================================================================
// NOTIFICATION MESSAGES
//=============================================================================

//-----------------------------------------------------------------------------
// player:accuses:wins:
//-----------------------------------------------------------------------------
- (void) player:(int)p accuses:(ClueSolution const*)buff wins:(BOOL)wins
    {
    if (p == [self playerID])
	{
	char const* s = (wins ? "You win!" : "You lose.");
	[messageField setStringValueNoCopy:s];
	}
    }


//=============================================================================
// DIALOGUE
//=============================================================================

//-----------------------------------------------------------------------------
// player:reveals:
//-----------------------------------------------------------------------------
- (void) player:(int)p reveals:(ClueCard)c
    {
    char buff[128];
    sprintf( buff, "player %d reveals %s.\n%s",
	p+1, ClueCardName(c), MAKE_ACCUSATION );
    [messageField setStringValue:buff];
    wasDisproved = YES;
    [self revealOk];
    }


//=============================================================================
// SUGGEST / ACCUSE
//=============================================================================
//-----------------------------------------------------------------------------
// finishSolution:
//-----------------------------------------------------------------------------
- (void) finishSolution:(BOOL)skip
    {
    ClueSolution* p = 0;
    if (!skip)
	{
	p = &suggestion;
	p->suspect() = ClueCard( [suspectPop selectedTag] );
	p->weapon() = ClueCard( [weaponPop selectedTag] );
	p->room() = ClueCard( [roomPop selectedTag] );
	}

    [suggestButton setEnabled:NO];
    [accuseButton setEnabled:NO];
    [skipButton setEnabled:NO];
    [suspectPop setEnabled:NO];
    [weaponPop setEnabled:NO];
    [roomPop setEnabled:NO];

    if (forAccuse)
	[self accuse:p];
    else
	[self suggest:p];
    }


- skipPressed:sender
    {
    if (!forAccuse)		// Suggestion skipped.
	{			// Restore suspect / weapon.
	[clueMgr movePiece:suspectID to:suspectPos];
	[clueMgr movePiece:weaponID to:weaponPos];
	}
    wasDisproved = YES;		// Suppress "nobody disproved".
    [messageField setStringValueNoCopy: MAKE_ACCUSATION];
    [self finishSolution:YES];
    return self;
    }


- accusePressed:sender
    {
    [self finishSolution:NO];
    return self;
    }


- suggestPressed:sender
    {
    [self finishSolution:NO];
    return self;
    }


- (void) movePiece:(ClueCard)piece
    toRoom:(ClueCard)room
    savePos:(ClueCoord*)savePos
    {
    ClueCoord const pos = [clueMgr pieceLocation:piece];
    *savePos = pos;
    if (ClueRoomAt( pos ) != room)
	[clueMgr movePiece:piece to:[clueMgr roomCoord:room]];
    }


- suspectSnap:sender
    {
    if (!forAccuse)
	{
	ClueCard const x = ClueCard( [suspectPop selectedTag] );
	if (x != suspectID)
	    {
	    [clueMgr movePiece:suspectID to:suspectPos];
	    suspectID = x;
	    [self movePiece:suspectID toRoom:currRoom savePos:&suspectPos];
	    }
	}
    return self;
    }


- weaponSnap:sender
    {
    if (!forAccuse)
	{
	ClueCard const x = ClueCard( [weaponPop selectedTag] );
	if (x != weaponID)
	    {
	    [clueMgr movePiece:weaponID to:weaponPos];
	    weaponID = x;
	    [self movePiece:weaponID toRoom:currRoom savePos:&weaponPos];
	    }
	}
    return self;
    }


//-----------------------------------------------------------------------------
// startSolution
//-----------------------------------------------------------------------------
- (void) startSolution
    {
    [skipButton setEnabled:YES];
    [suspectPop setEnabled:YES];
    [weaponPop setEnabled:YES];
    [window makeKeyAndOrderFront:self];
    }


//-----------------------------------------------------------------------------
// makeSuggestion
//-----------------------------------------------------------------------------
- (void) makeSuggestion
    {
    ClueCard const curr_room = ClueRoomAt( [self location] );
    if (curr_room != CLUE_CARD_MAX && curr_room != last_room)
	{
	wasDisproved = NO;
	forAccuse = NO;
	currRoom = curr_room;

	[messageField setStringValueNoCopy:"Make a suggestion or skip."];
	[suggestButton setEnabled:YES];
	[roomPop selectTag: int(curr_room)];

	suspectID = ClueCard( [suspectPop selectedTag] );
	[self movePiece:suspectID toRoom:currRoom savePos:&suspectPos];

	weaponID = ClueCard( [weaponPop selectedTag] );
	[self movePiece:weaponID toRoom:currRoom savePos:&weaponPos];

	[self startSolution];

	ClueCoordArray obstacles;
	map->allSquaresInRoom( curr_room, obstacles );

	for (int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	    draggable[i] = true;

	forMove = NO;
	[self allowDrag];
	}
    else
	{
	wasDisproved = YES;	// Suppress "nobody disproved" message.
	[messageField setStringValueNoCopy: MAKE_ACCUSATION];
	[self suggest:0];
	}
    }


//-----------------------------------------------------------------------------
// startAccuse
//-----------------------------------------------------------------------------
- (void) startAccuse
    {
    forAccuse = YES;
    [accuseButton setEnabled:YES];
    [roomPop setEnabled:YES];
    [self startSolution];
    }


//-----------------------------------------------------------------------------
// makeAccusation
//-----------------------------------------------------------------------------
- (void) makeAccusation
    {
    if (!wasDisproved)
	{
	char buff[ 128 ];
	sprintf( buff, "Nobody can disprove your suggestion.\n%s",
			MAKE_ACCUSATION );
	[messageField setStringValue: buff];
	}
    [self startAccuse];
    }


//=============================================================================
// DISPROVE
//=============================================================================
//-----------------------------------------------------------------------------
// revealPressed:
//-----------------------------------------------------------------------------
- revealPressed:sender
    {
    [revealButton setEnabled:NO];
    [revealMatrix setEnabled:NO];

    int const row = [revealMatrix selectedRow];
    assert( 0 <= row && row < int(CLUE_CATEGORY_COUNT) );
    ClueCard x = suggestion.v[ row ];

    [self reveal:x];
    return self;
    }


//-----------------------------------------------------------------------------
// setRevealCell:forCard:
//-----------------------------------------------------------------------------
- (void) setRevealCell:(int)row forCard:(ClueCard)x
    {
    ButtonCell* cell = [revealMatrix cellAt:row:0];
    [cell setEnabled:[self amHoldingCard:x]];
    [cell setTitle: ClueCardName(x)];
    [cell setTag:x];
    [cell setState:0];
    }


//-----------------------------------------------------------------------------
// fixRevealMatrix
//-----------------------------------------------------------------------------
- (void) fixRevealMatrix
    {
    [revealMatrix setEmptySelectionEnabled:NO];
    for (int i = 0; i < 3; i++)
	{
	Cell* cell = [revealMatrix cellAt:i:0];
	if ([cell isEnabled])
	    {
	    [cell setState:1];
	    [revealMatrix selectCellAt:i:0];
	    break;
	    }
	}
    [revealMatrix display];
    }


//-----------------------------------------------------------------------------
// disprove:forPlayer:
//-----------------------------------------------------------------------------
- (void) disprove:(ClueSolution const*)solution forPlayer:(int)playerID
    {
    BOOL have_one = false;
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	if ([self amHoldingCard:solution->v[i]])
	    { have_one = true; break; }

    if (have_one)
	{
	suggestion = *solution;
	[messageField setStringValueNoCopy:
			"Reveal a card to disprove this suggestion."];

	[revealButton setEnabled:YES];
	[revealMatrix setEnabled:YES];

	for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
	    [self setRevealCell:i forCard:solution->v[i]];

	[self fixRevealMatrix];
	[window makeKeyAndOrderFront:self];
	}
    else
	[self reveal:CLUE_CARD_MAX];
    }


//=============================================================================
// MOVE
//=============================================================================
//-----------------------------------------------------------------------------
// disableMoveButtons
//-----------------------------------------------------------------------------
- (void) disableMoveButtons
    {
    [stayButton setEnabled:NO];
    [passageButton setEnabled:NO];
    [rollButton setEnabled:NO];
    [dieButton setEnabled:NO];
    }


//-----------------------------------------------------------------------------
// finishMove:
//-----------------------------------------------------------------------------
- (void) finishMove:(ClueCoord)coord
    {
    [self disableMoveButtons];
    [self moveTo:coord];
    }


//-----------------------------------------------------------------------------
// stayPressed:
//-----------------------------------------------------------------------------
- stayPressed:sender
    {
    [self finishMove:[self location]];
    return self;
    }


//-----------------------------------------------------------------------------
// passagePressed:
//-----------------------------------------------------------------------------
- passagePressed:sender
    {
    ClueCoord pos = [clueMgr roomCoord:passageRoom];
    [self finishMove:pos];
    return self;
    }


//-----------------------------------------------------------------------------
// piece:from:droppedAt:
//-----------------------------------------------------------------------------
- (void) piece:(ClueCard)piece from:(ClueCoord)oldPos
	droppedAt:(ClueCoord)newPos
    {
    if (forMove)
	{
	if (piece == [self pieceID] && map->isLegal( newPos ))
	    {
	    forMove = NO;
	    [self moveTo:newPos];
	    }
	else
	    [self allowDrag];
	}
    else
	{
	if (piece <= CLUE_SUSPECT_LAST)
	    {
	    if (piece != suspectID)
		{
		[clueMgr movePiece:suspectID to:suspectPos];
		suspectID = piece;
		suspectPos = oldPos;
		[suspectPop selectTag:int(piece)];
		}
	    }
	else
	    {
	    if (piece != weaponID)
		{
		[clueMgr movePiece:weaponID to:weaponPos];
		weaponID = piece;
		weaponPos = oldPos;
		[weaponPop selectTag:int(piece)];
		}
	    }
	[self allowDrag];
	}
    }


//-----------------------------------------------------------------------------
// makeMapForRoll:
//-----------------------------------------------------------------------------
- (bool) makeMapForRoll:(int)die_roll
    {
    ClueCoordArray obstacles;
    int const self_piece = int([self pieceID]);
    for (int i = 0; i < CLUE_SUSPECT_COUNT; i++)
	if (i != self_piece)
	    obstacles.append( [clueMgr pieceLocation:ClueCard(i)] );
    return map->calcLegal( die_roll, [self location], obstacles );
    }


//-----------------------------------------------------------------------------
// rollPressed:
//-----------------------------------------------------------------------------
- rollPressed:sender
    {
    [self disableMoveButtons];

    int const die_roll = [clueMgr rollDie];

    [dieButton setIcon: DIE_ICON[ die_roll - 1 ]];

    char buff[128];
    if ([self makeMapForRoll:die_roll])
	{
	sprintf( buff, "You rolled %d.\nMove your piece.", die_roll );
	}
    else
	{
	int n = die_roll;
	do { --n; assert( n != 0 ); }
	while (![self makeMapForRoll:n]);
	sprintf( buff, "You rolled %d, but can only use %d.\n"
			"Move your piece.", die_roll, n );
	}
    [messageField setStringValue:buff];

    memset( draggable, 0, sizeof(draggable) );
    draggable[ [self pieceID] ] = true;

    forMove = YES;

    [self allowDrag];

    return self;
    }


//-----------------------------------------------------------------------------
// makeMove
//-----------------------------------------------------------------------------
- (void) makeMove
    {
    [stayButton setEnabled: can_stay];

    passageRoom = CLUE_CARD_MAX;
    ClueCard const room = ClueRoomAt( [self location] );
    if (room != CLUE_CARD_MAX)
	passageRoom = CLUE_PASSAGE[ room - CLUE_ROOM_FIRST ];
    BOOL const has_passage = passageRoom != CLUE_CARD_MAX;
    [passageButton setEnabled: has_passage];

    bool const can_roll = [self makeMapForRoll:1];
    [rollButton setEnabled: can_roll];
    [dieButton setEnabled: can_roll];

    if (can_stay || has_passage || can_roll)
	[messageField setStringValueNoCopy:"Your move."];
    else
	{
	[messageField setStringValueNoCopy:"No legal move.  Press stay."];
	[stayButton setEnabled:YES];
	}

    [window makeKeyAndOrderFront:self];
    }

@end
