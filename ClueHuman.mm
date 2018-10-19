//-----------------------------------------------------------------------------
// ClueHuman.M
//
//	Human player UI for the Clue app.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueHuman.M,v 1.4 97/09/21 01:27:12 zarnuk Exp $
// $Log:	ClueHuman.M,v $
//  Revision 1.4  97/09/21  01:27:12  zarnuk
//  v25 -- Converted to Misc version of table scroll.
//  
//  Revision 1.3  97/06/27  08:53:09  zarnuk
//  v23 -- Turned off sorting in the table scroll.  Eric added stuff
//  to keep first responder if the user presses enter.
//  
//  Revision 1.2  97/05/31  12:53:32  zarnuk
//  v21: Fixed bug sometimes restored pieces on top of other pieces.
//  
//  Revision 1.1  97/05/31  10:09:45  zarnuk
//  v21
//-----------------------------------------------------------------------------
#import "ClueHuman.h"
#import	"ClueBoardView.h"
#import	"ClueCoordArray.h"
#import	"ClueLoadNib.h"
#import	"ClueMap.h"
#import	"ClueMgr.h"

#import	<MiscTableScroll/MiscTableScroll.h>
#import	<MiscTableScroll/MiscTableCell.h>
@class MiscTableCell;

#import <Cocoa/Cocoa.h>

extern "C" {
#import	<assert.h>
#import	<stdio.h>
#import	<string.h>
}

enum {
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

NSString * const MAKE_ACCUSATION = @"Make an accusation or skip.";

@interface ClueHuman()
- (void) startAccuse;
@end

static BOOL VERTICAL_MOVEMENT = NO;
extern "C" unsigned short NSFieldFilter( unsigned short c, NSEventModifierFlags flags, unsigned short cset );

//-----------------------------------------------------------------------------
// ClueFilter
//-----------------------------------------------------------------------------
static unsigned short
ClueFilter( unsigned short c, NSEventModifierFlags flags, unsigned short cset )
{
    enum { KEY_UP = 0xad, KEY_DOWN = 0xaf };
    NSEventModifierFlags const BAD = (NSEventModifierFlagControl | NSEventModifierFlagOption | NSEventModifierFlagCommand);
    if ((flags & BAD) == 0 && cset == NX_SYMBOLSET)
    {
        if (c == KEY_UP)
        {
            VERTICAL_MOVEMENT = YES;
            return NSBacktabTextMovement;
        }
        else if (c == KEY_DOWN)
        {
            VERTICAL_MOVEMENT = YES;
            return NSTabTextMovement;
        }
    }
    VERTICAL_MOVEMENT = NO;
    return NSFieldFilter( c, flags, cset );
}


//=============================================================================
// IMPLEMENTATION
//=============================================================================
@implementation ClueHuman

- (BOOL) isHuman		{ return YES; }
- (NSString*) playerName	{ return @"Human"; }

- (void)print:(id)x	{ [window print:self];
}

//-----------------------------------------------------------------------------
// free
//-----------------------------------------------------------------------------
- (void)dealloc
{
    delete map;
    [scroll abortEditing];
    [fieldEditor release];
    [window close];
    [window release];
    [super dealloc];
}


//-----------------------------------------------------------------------------
// separatorRow:tag:name:
//-----------------------------------------------------------------------------
- (void) separatorRow:(int)row tag:(int)tag name:(char const*)name
{
    MiscTableCell* cell;
    cell = [scroll cellAtRow:row column:ICON_SLOT];
    [cell setTag:tag];
    cell = [scroll cellAtRow:row column:NAME_SLOT];
    [cell setTag:tag];
    [cell setStringValue:[NSString stringWithCString:name]];

    for (int i = MAX_SLOT; i-- > 0; )
    {
        cell = [scroll cellAtRow:row column:i];
        [cell setSelectedBackgroundColor:[NSColor darkGrayColor]];
        [cell setBackgroundColor:[NSColor darkGrayColor]];
        [cell setTextColor:[NSColor whiteColor]];
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
        MiscTableCell* cell;

        if (last_cat != cat)
        {
            last_cat = cat;
            int const x = (tag & ~1);	// Mask off low bit.
            [self separatorRow:row++ tag:x name:ClueCategoryName(cat)];
        }

        cell = [scroll cellAtRow:row column:ICON_SLOT];
        [cell setImage:[NSImage imageNamed:@(ClueCardName(card))]];
        [cell setTag:tag];

        cell = [scroll cellAtRow:row column:NAME_SLOT];
        [cell setStringValue:@(ClueCardName(card))];
        [cell setTag:tag];

        [[scroll cellAtRow:row column:self_slot] setStringValue:([self amHoldingCard:card] ? @"x" : @"-")];
    }

    [self separatorRow:row tag:(CLUE_CARD_COUNT << 1) name:"notes"];
}


//-----------------------------------------------------------------------------
// initPlayer:numPlayers:numCards:cards:piece:location:
//-----------------------------------------------------------------------------
- (instancetype)initWithPlayer:(int)playerID playerCount:(int)numPlayers
                     cardCount:(int)numCards cards:(ClueCard const*)i_cards
                         piece:(ClueCard)pieceID location:(ClueCoord)i_location
                   clueManager:(ClueMgr*)mgr
{
    if (self = [super initWithPlayer:playerID playerCount:numPlayers
                   cardCount:numCards cards:i_cards piece:pieceID
                            location:i_location clueManager:mgr]) {

        ClueLoadNib( self );
        fieldEditor = [[NSText allocWithZone:[self zone]] init];
        [fieldEditor setCharFilter:ClueFilter];

        [suspectPop selectItemWithTag: [self pieceID]];
        [weaponPop selectItemWithTag: CLUE_CARD_KNIFE];
        [roomPop selectItemWithTag: CLUE_CARD_HALL];

        map = new ClueMap;

        [window setFrameAutosaveName:@"ClueHumanWindow"];

        char const* const piece_name = ClueCardName( pieceID );
        [window setTitle:[NSString stringWithFormat:@"Player %d -- %s", playerID + 1, piece_name]];

        [self initScroll];

        [messageField setStringValue:@"New Game"];

        [window makeKeyAndOrderFront:self];
    }
    
    return self;
}


//-----------------------------------------------------------------------------
// tableScroll:canEdit:at::
//-----------------------------------------------------------------------------
-  (BOOL)tableScroll:(MiscTableScroll*)ts
    canEdit:(NSEvent *)event at:(int)row :(int)col
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
- (void)editNext:(BOOL)next row:(MiscCoord_P)p_row col:(MiscCoord_P)p_col
{
    int const nrows = [scroll numberOfRows];
    MiscCoord_V v_row = [scroll rowPosition:p_row];

    v_row += (next ? 1 : -1);
    if (v_row >= nrows) v_row = 0;
    else if (v_row < 0) v_row = nrows - 1;

    p_row = [scroll rowAtPosition:v_row];
    if ([scroll canEdit:0 atRow:p_row column:p_col])
        [scroll editCellAtRow:p_row column:p_col];
}


//-----------------------------------------------------------------------------
// textDidEnd:endChar:
//-----------------------------------------------------------------------------
#warning NotificationConversion: 'textDidEndEditing:' used to be 'textDidEnd:'.  This conversion assumes this method is implemented or sent to a delegate of NSText.  If this method was implemented by a NSMatrix or NSTextField textDelegate, use the text notifications in NSControl.h.
- (void)textDidEndEditing:(NSNotification *)notification
{
#warning NotificationConversion: if this notification was not posted by NSText (eg. was forwarded by NSMatrix or NSTextField from the field editor to their textDelegate), then the text object is found by [[notification userInfo] objectForKey:@"NSFieldEditor"] rather than [notification object]
    NSText *theText = [notification object];
    int whyEnd = [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue];
    MiscCoord_P row = [scroll clickedRow];
    MiscCoord_P col = [scroll clickedColumn];
    switch (whyEnd)
    {
        case NSTabTextMovement:
            if (VERTICAL_MOVEMENT)
                [self editNext:YES row:row col:col];
            else if ([scroll getNext:YES editRow:&row column:&col])
                [scroll editCellAtRow:row column:col];
            break;
        case NSBacktabTextMovement:
            if (VERTICAL_MOVEMENT)
                [self editNext:NO row:row col:col];
            else if ([scroll getNext:NO editRow:&row column:&col])
                [scroll editCellAtRow:row column:col];
            break;
        case NSReturnTextMovement:
            [scroll selectText:self];
            [scroll sendAction];
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
        [messageField setStringValue:(wins ? @"You win!" : @"You lose.")];
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
    [messageField setStringValue:[NSString stringWithFormat:@"player %d reveals %s.\n%@",
                                  p+1, ClueCardName(c), MAKE_ACCUSATION]];
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


- (void) restorePiece:(ClueCard)piece to:(ClueCoord)pos
{
    if ([clueMgr pieceAt:pos] != CLUE_CARD_MAX)
    {
        ClueCard const room = ClueRoomAt( pos );
        assert( room != CLUE_CARD_MAX );
        pos = [clueMgr roomCoord:room];
    }
    [clueMgr movePiece:piece to:pos];
}


- skipPressed:sender
{
    if (!forAccuse)		// Suggestion skipped.
    {			// Restore suspect / weapon.
        [self restorePiece:suspectID to:suspectPos];
        [self restorePiece:weaponID to:weaponPos];
    }
    wasDisproved = YES;		// Suppress "nobody disproved".
    [messageField setStringValue:MAKE_ACCUSATION];
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
            [self restorePiece:suspectID to:suspectPos];
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
            [self restorePiece:weaponID to:weaponPos];
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
        
        [messageField setStringValue:@"Make a suggestion or skip."];
        [suggestButton setEnabled:YES];
        [roomPop selectItemWithTag: int(curr_room)];
        
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
        [messageField setStringValue:MAKE_ACCUSATION];
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
        [messageField setStringValue:[NSString stringWithFormat:@"Nobody can disprove your suggestion.\n%@",
                                      MAKE_ACCUSATION]];
    }
    [self startAccuse];
}


//=============================================================================
// DISPROVE
//=============================================================================
//-----------------------------------------------------------------------------
// revealPressed:
//-----------------------------------------------------------------------------
- (IBAction)revealPressed:sender
{
    [revealButton setEnabled:NO];
    [revealMatrix setEnabled:NO];

    NSInteger const row = [revealMatrix selectedRow];
    assert( 0 <= row && row < int(CLUE_CATEGORY_COUNT) );
    ClueCard x = suggestion.v[ row ];

    [self reveal:x];
}


//-----------------------------------------------------------------------------
// setRevealCell:forCard:
//-----------------------------------------------------------------------------
- (void) setRevealCell:(int)row forCard:(ClueCard)x
{
    NSButtonCell* cell = [revealMatrix cellAtRow:row column:0];
    [cell setEnabled:[self amHoldingCard:x]];
    [cell setTitle:@(ClueCardName(x))];
    [cell setTag:x];
    [cell setState:0];
}


//-----------------------------------------------------------------------------
// fixRevealMatrix
//-----------------------------------------------------------------------------
- (void) fixRevealMatrix
{
    [revealMatrix setAllowsEmptySelection:NO];
    for (int i = 0; i < 3; i++)
    {
        NSCell* cell = [revealMatrix cellAtRow:i column:0];
        if ([cell isEnabled])
        {
            [cell setState:1];
            [revealMatrix selectCellAtRow:i column:0];
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
        [messageField setStringValue:@"Reveal a card to disprove this suggestion."];

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
- (IBAction)stayPressed:sender
{
    [self finishMove:[self location]];
}


//-----------------------------------------------------------------------------
// passagePressed:
//-----------------------------------------------------------------------------
- (IBAction)passagePressed:sender
{
    ClueCoord pos = [clueMgr roomCoord:passageRoom];
    [self finishMove:pos];
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
                [self restorePiece:suspectID to:suspectPos];
                suspectID = piece;
                suspectPos = oldPos;
                [suspectPop selectItemWithTag:int(piece)];
            }
        }
        else
        {
            if (piece != weaponID)
            {
                [self restorePiece:weaponID to:weaponPos];
                weaponID = piece;
                weaponPos = oldPos;
                [weaponPop selectItemWithTag:int(piece)];
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
- (IBAction)rollPressed:sender
{
    [self disableMoveButtons];

    int const die_roll = [clueMgr rollDie];

    [dieButton setImage:[NSImage imageNamed:@(DIE_ICON[ die_roll - 1 ])]];

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
    [messageField setStringValue:@(buff)];

    memset( draggable, 0, sizeof(draggable) );
    draggable[ [self pieceID] ] = true;

    forMove = YES;

    [self allowDrag];
}


//-----------------------------------------------------------------------------
// makeMove
//-----------------------------------------------------------------------------
- (void) makeMove
{
    [stayButton setEnabled:can_stay];

    passageRoom = CLUE_CARD_MAX;
    ClueCard const room = ClueRoomAt( [self location] );
    if (room != CLUE_CARD_MAX)
        passageRoom = CLUE_PASSAGE[ room - CLUE_ROOM_FIRST ];
    BOOL const has_passage = passageRoom != CLUE_CARD_MAX;
    [passageButton setEnabled:has_passage];

    bool const can_roll = [self makeMapForRoll:1];
    [rollButton setEnabled:can_roll];
    [dieButton setEnabled:can_roll];

    if (can_stay || has_passage || can_roll)
        [messageField setStringValue:@"Your move."];
    else
    {
        [messageField setStringValue:@"No legal move.  Press stay."];
        [stayButton setEnabled:YES];
    }
    
    [window makeKeyAndOrderFront:self];
}

@end
