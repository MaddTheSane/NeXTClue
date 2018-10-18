//-----------------------------------------------------------------------------
// ClueBoardView.M
//
//	Custom view that manages the display of the board and the drag and
//	drop interaction with it.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine. All rights reserved.
//
// *FIXME* This implementation is total ugliness! (puke)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueBoardView.M,v 1.1 97/05/31 10:07:32 zarnuk Exp $
// $Log:	ClueBoardView.M,v $
//  Revision 1.1  97/05/31  10:07:32  zarnuk
//  First Revision.
//  
//-----------------------------------------------------------------------------
#import "ClueBoardView.h"
#import "ClueCoordArray.h"
#import	"ClueMap.h"
#import "ClueMgr.h"
#import <AppKit/NSApplication.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSColor.h>

extern "C" {
#import <assert.h>
#import <string.h>	// memset()
//#import <AppKit/psops.h>
}

static char const* const BOARD_IMAGE = "board";
int const TILE_SIZE = 20;

struct CL_RegionRel
	{
	int width;
	int height;
	NSImage* image;
	};

struct CL_RegionAbs
	{
	ClueCoord origin;
	CL_RegionRel* region;
	int region_id;
	};

static CL_RegionAbs REGIONS[ CLUE_ROW_MAX ][ CLUE_COL_MAX ];

static inline float absval( float x ) { return (x < 0 ? -x : x ); }
static inline BOOL isSlop(NSEvent *const* e1,NSEvent *const* e2,
			   float const slop)
    {
    return (absval(e1->location.x - e2->location.x) <= slop &&
	    absval(e1->location.y - e2->location.y) <= slop);
    }

static inline bool is_regionable( char c )
    {
    char s[2]; s[0] = c; s[1] = '\0';
    return (strpbrk( s, "0123456789.^Vv<>" ) != 0); // FIXME: Need global defs
    }

static inline bool is_same_region( char c_old, char c_new )
    {
    return (c_new == c_old && c_old >= '0' && c_old <= '9'); // FIXME: ditto
    }


@implementation ClueBoardView

+ (void)initRegions
    {
    static ClueCoord const NEIGHBORS[] = 
		{{ 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 }};
    int const NUM_NEIGHBORS = sizeof(NEIGHBORS) / sizeof(NEIGHBORS[0]);

    NSRect r = {{ 0, 0 }, { TILE_SIZE, TILE_SIZE }};
    NSImage* unit_image = [[NSImage alloc] initWithSize:r.size];
    [unit_image lockFocus];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:1 alpha:0.5] set];
//      NXSetColor( NXConvertRGBAToColor(0,1,0,0.40) );
    NSRectFill(r);
    [unit_image unlockFocus];

    CL_RegionRel* unit_region = new CL_RegionRel;
    unit_region->width = 1;
    unit_region->height = 1;
    unit_region->image = unit_image;

    char board[ CLUE_ROW_MAX ][ CLUE_COL_MAX + 1 ];
    memcpy( board, CLUE_BOARD, sizeof(board) );

    int region_id = 0;
    memset( REGIONS, 0, sizeof(REGIONS) );

    for (int i = 0; i < CLUE_ROW_MAX; i++)
	{
	for (int j = 0; j <CLUE_COL_MAX; j++)
	    {
	    char const c = board[i][j];
	    if (is_regionable(c))
		{
		ClueCoordArray stack;
		ClueCoordArray list;
		ClueCoord coord = { i, j };
		stack.push( coord );
		while (!stack.is_empty())
		    {
		    coord = stack.pop();
		    char const c_new = board[coord.row][coord.col];
		    if (is_same_region( c, c_new ))
			{
			list.append( coord );
			board[coord.row][coord.col] = ' ';
			for (int k = 0; k < NUM_NEIGHBORS; k++)
			    {
			    ClueCoord next;
			    next.row = coord.row + NEIGHBORS[k].row;
			    next.col = coord.col + NEIGHBORS[k].col;
			    if (next.row >= 0 && next.row < CLUE_ROW_MAX &&
				next.col >= 0 && next.col < CLUE_COL_MAX)
				stack.push( next );
			    }
			}
		    }

		region_id++;
		int const n = list.count();
		if (n <= 1)
		    {
		    CL_RegionAbs& reg = REGIONS[i][j];
		    reg.origin.row = i;
		    reg.origin.col = j;
		    reg.region = unit_region;
		    reg.region_id = region_id;
		    }
		else
		    {
		    int k;
		    int row_min = CLUE_ROW_MAX;
		    int row_max = 0;
		    int col_min = CLUE_COL_MAX;
		    int col_max = 0;
		    for (k = 0; k < n; k++)
			{
			coord = list[k];
			if (coord.row < row_min) row_min = coord.row;
			if (coord.row > row_max) row_max = coord.row;
			if (coord.col < col_min) col_min = coord.col;
			if (coord.col > col_max) col_max = coord.col;
			}
		    int const width = col_max - col_min + 1;
		    int const height = row_max - row_min + 1;

		    r.origin.x = r.origin.y = 0;
		    r.size.width = width * TILE_SIZE;
		    r.size.height = height * TILE_SIZE;
		    NSImage* image = [[NSImage alloc] initWithSize:r.size];

		    CL_RegionRel* region = new CL_RegionRel;
		    region->width = width;
		    region->height = height;
		    region->image = image;

		    [image lockFocus];
		    [[NSColor clearColor] set];
		    NSRectFill(r);
		    for (k = 0; k < n; k++)
			{
			coord = list[k];
			int row_origin = height + row_min - coord.row - 1;
			int col_origin = coord.col - col_min;
			NSPoint const pt = { col_origin * TILE_SIZE,
					     row_origin * TILE_SIZE };
			[unit_image compositeToPoint:pt operation:NSCompositeCopy];

			CL_RegionAbs& reg = REGIONS[coord.row][coord.col];
			reg.origin.row = row_max;
			reg.origin.col = col_min;
			reg.region = region;
			reg.region_id = region_id;
			}
		    [image unlockFocus];
		    }
		}
	    }
	}
    }

+ (void)initialize
    {
    if (self == [ClueBoardView class])
	[self initRegions];
    return;
    }

- (id)initWithFrame:(NSRect)rect
    {
    [super initWithFrame:rect];
#error ViewConversion: 'setClipping:' is obsolete. Views always clip to their bounds. Use PSinitclip instead.
    [self setClipping:NO];
    [self registerForDraggedTypes:[NSArray arrayWithObject:[NSString stringWithCString:CLUE_CARD_PBTYPE]]];
    background = [NSImage imageNamed:[NSString stringWithCString:BOARD_IMAGE]];
    for (int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	pieces[i] = [NSImage imageNamed:[NSString stringWithCString:ClueCardName(ClueCard(i))]];
    dragging = NO;
    fade = [[NSImage allocWithZone:[self zone]] init];
    return self;
    }

- (BOOL)isOpaque
{
    return YES;
}

- (void)dealloc
    {
    // Don't free 'background' or 'pieces; -- they are shared/named images.
    [self unregisterDraggedTypes];
    [fade release];
    { [super dealloc]; return; };
    }

#warning ViewConversion: 'acceptsFirstMouse:' (used to be 'acceptsFirstMouse') now takes the event as an arg
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
    {
    return YES;
    }

- (NSPoint)pointAtCoord:(ClueCoord)coord
    {
    NSPoint p;
    p.x = coord.col * TILE_SIZE;
    p.y = (CLUE_ROW_MAX - coord.row - 1) * TILE_SIZE;
    return p;
    }

- (NSRect)rectAtCoord:(ClueCoord)coord
    {
    NSRect r;
    r.origin = [self pointAtCoord:coord];
    r.size.width = TILE_SIZE;
    r.size.height = TILE_SIZE;
    return r;
    }

- (void)displayAt:(ClueCoord)coord
    {
    NSRect const r = [self rectAtCoord:coord];
    [self displayRect:r];
    }

// *NOTE*
// The board image is actually 1 pixel wider and higher than it needs to be
// to contain the grid (the extra pixel is used for a black border), hence
// the conditionals.
- (ClueCoord)coordAtPoint:(NSPoint)pt
    {
    ClueCoord coord;
    coord.col = int( pt.x / TILE_SIZE );
    coord.row = CLUE_ROW_MAX - 1 - int( pt.y / TILE_SIZE );
    if (coord.col >= CLUE_COL_MAX) coord.col = CLUE_COL_MAX - 1;
    else if (coord.col < 0) coord.col = 0;
    if (coord.row >= CLUE_ROW_MAX) coord.row = CLUE_ROW_MAX - 1;
    else if (coord.row < 0) coord.row = 0;
    return coord;
    }

- (NSPoint)originAtCoord:(ClueCoord)coord forSize:(NSSize)size
    {
    assert( size.width < TILE_SIZE );
    assert( size.height < TILE_SIZE );
    NSRect r = [self rectAtCoord:coord];
    NSPoint p;
    p.x = r.origin.x + (r.size.width - size.width) / 2.0;
    p.y = r.origin.y + (r.size.height - size.height) / 2.0;
    return p;
    }

- (ClueCard)pieceAtCoord:(ClueCoord)coord
    {
    for (int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	{
	ClueCoord const loc = [clueMgr pieceLocation:(ClueCard)i];
	if (loc.row == coord.row && loc.col == coord.col)
	    return ClueCard(i);
	}
    return CLUE_CARD_MAX;
    }

- (void)drawPieces:(NSRect const*)draw_rect
    {
    for (int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	{
	ClueCoord const coord = [clueMgr pieceLocation:(ClueCard)i];
	NSRect const r = [self rectAtCoord:coord];
	if (!NSIsEmptyRect(NSIntersectionRect(*draw_rect , r)))
	    {
	    NSSize s; s = [pieces[i] size];
	    NSPoint const p = [self originAtCoord:coord forSize:s];
	    if (dragging &&
		dragSource.row == coord.row && dragSource.col == coord.col)
		[fade compositeToPoint:p operation:NSCompositeSourceOver];
	    else
		[pieces[i] compositeToPoint:p operation:NSCompositeSourceOver];
	    }
	}
    }

#warning RectConversion: drawRect:(NSRect)rects (used to be drawSelf:(NXRect const*)rects :(int)nrects) no longer takes an array of rects
- (void)drawRect:(NSRect)rects
    {
    [background compositeToPoint:rects.origin fromRect:rects operation:NSCompositeCopy];
    [self drawPieces:&rects];
}

- (void)setClueMgr:(ClueMgr*)p
    {
    clueMgr = p;
    }

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag
    {
    return NSDragOperationGeneric;
    }

- (BOOL)ignoreModifierKeysWhileDragging
    {
    return YES;
    }

- (void)fadeOut:(NSImage*)i at:(ClueCoord)coord
    {
    dragging = YES;
    dragSource = coord;

    NSSize s; s = [i size];
    [fade setSize:s];

    [fade lockFocus];
    NSRect r = {{ 0, 0 }, { s.width, s.height }};
    [[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5] set];
    NSRectFill(r);
    NSPoint const zero = {0,0};
    [i compositeToPoint:zero operation:NSCompositeDestinationAtop];
    [fade unlockFocus];
    r = [self rectAtCoord:coord];
    [self displayRect:r];
    }

- (void)fadeInAt:(ClueCoord)coord
    {
    dragging = NO;
    [self displayAt:coord];
    }

- (void) movePiece:(ClueCard)piece
	from:(ClueCoord)old_pos to:(ClueCoord)new_pos
    {
    [self displayAt:old_pos];
    [self displayAt:new_pos];
    [[self window] flushWindow];
    }


- (void)performDrag:(NSEvent *)downEvent at:(ClueCoord)coord
    dragEvent:(NSEvent *)dragEvent
    {
    ClueCard const piece = [self pieceAtCoord:coord];
    assert( piece < CLUE_CARD_MAX );
    NSImage* const i = pieces[ piece ];
    NSSize s; s = [i size];
    NSPoint origin = [self originAtCoord:coord forSize:s];
    NSPoint offset = {0,0};
    if (dragEvent != 0 && dragEvent->type == NSLeftMouseDragged)
	{
	offset.x = dragEvent->location.x - [downEvent locationInWindow].x;
	offset.y = dragEvent->location.y - [downEvent locationInWindow].y;
	}
    
    NSPasteboard* pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pb declareTypes:[NSArray arrayWithObject:[NSString stringWithCString:CLUE_CARD_PBTYPE]] owner:0];
    [pb setData:[NSData dataWithBytes:(char const*)&piece length:sizeof(piece)] forType:[NSString stringWithCString:CLUE_CARD_PBTYPE]];
    
    [self fadeOut:i at:coord];
    [self dragImage:i at:origin offset:NSMakeSize((&offset)->x,(&offset)->y) event:downEvent pasteboard:pb source:self slideBack:YES];
    [self fadeInAt:coord];
    }

- (void)awaitDrag:(NSEvent *)p at:(ClueCoord)coord
    {
    float const DELAY = 0.25;
    float const SLOP = 4.0;
    int const WANTED = (NSLeftMouseUpMask | NSLeftMouseDraggedMask);

    NSEvent *mouseDown = p;
    NSEvent *event;
    NSEvent *peeker;
#error EventConversion: addToEventMask:WANTED: is obsolete; you no longer need to use the eventMask methods; for mouse moved events, see 'setAcceptsMouseMovedEvents:'
    int oldMask = [[self window] addToEventMask:WANTED];

    do	{
	event = (peeker = [[self window] nextEventMatchingMask:WANTED untilDate:[NSDate dateWithTimeIntervalSinceNow:DELAY] inMode:NSEventTrackingRunLoopMode dequeue:NO]);
	if (event != 0 && [event type] == NSLeftMouseDragged)
	    event = [[self window] nextEventMatchingMask:NSLeftMouseDraggedMask];
	} while (event != 0 && [event type] == NSLeftMouseDragged && 
		isSlop( event, mouseDown, SLOP ));

#error EventConversion: setEventMask:oldMask: is obsolete; you no longer need to use the eventMask methods; for mouse moved events, see 'setAcceptsMouseMovedEvents:'
    [[self window] setEventMask:oldMask];

    if (event == 0 || [event type] == NSLeftMouseDragged)
	[self performDrag:mouseDown at:coord dragEvent:event];
    }

- (BOOL)canPerformDrag:(NSEvent *)p at:(ClueCoord)coord
    {
    ClueCard const piece = [self pieceAtCoord:coord];
    return piece < CLUE_CARD_MAX && draggable != 0 && draggable[piece];
    }

- (void)mouseDown:(NSEvent *)ev 
    {
    NSPoint pt = [ev locationInWindow];
    pt = [self convertPoint:pt fromView:0];
    ClueCoord const coord = [self coordAtPoint:pt];
    if ([self canPerformDrag:ev at:coord])
	[self awaitDrag:ev at:coord];
}

- (void)unhighlight
    {
    if (highlighting)
	{
	highlighting = NO;
	CL_RegionAbs const& reg =
		REGIONS[highlightCoord.row][highlightCoord.col];
	NSRect r;
	r.origin = [self pointAtCoord:reg.origin];
	r.size.width = reg.region->width * TILE_SIZE;
	r.size.height = reg.region->height * TILE_SIZE;
	[self displayRect:r];
	}
    }

- (unsigned int)highlightUnder:(id<NSDraggingInfo>)sender
    {
    NSPoint pt = [sender draggingLocation];
    pt = [self convertPoint:pt fromView:0];
    ClueCoord const coord = [self coordAtPoint:pt];
    CL_RegionAbs const& r = REGIONS[coord.row][coord.col];

    BOOL const ok = map != 0 && map->isLegal( coord ) &&	// legal coord
		[self pieceAtCoord:coord] == CLUE_CARD_MAX;	// empty coord

    if (highlighting)
	{
	CL_RegionAbs const& r_old =
		REGIONS[ highlightCoord.row ][ highlightCoord.col];
	if (r.region_id != r_old.region_id) // || !ok)
	   [self unhighlight];
	}

    if (!highlighting && ok)
	{
	if (r.region != 0)
	    {
	    highlighting = YES;
	    highlightCoord = coord;
	    NSPoint pt = [self pointAtCoord:r.origin];
	    [self lockFocus];
	    [r.region->image compositeToPoint:pt operation:NSCompositeSourceOver];
	    [self unlockFocus];
	    [[self window] flushWindow];
	    }
	}

    return (ok ? NSDragOperationGeneric : NSDragOperationNone);
    }

- (unsigned int)draggingEntered:(id<NSDraggingInfo>)sender
    {
    return [self highlightUnder:sender];
    }

- (void)draggingExited:(id <NSDraggingInfo>)sender
    {
    [self unhighlight];
}

- (unsigned int)draggingUpdated:(id<NSDraggingInfo>)sender
    {
    return [self highlightUnder:sender];
    }

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
    {
    [self unhighlight];
    return YES;
    }

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
    {
    NSPoint pt = [sender draggingLocation];
    pt = [self convertPoint:pt fromView:0];
    ClueCoord const coord = [self coordAtPoint:pt];

    NSPasteboard* pb = [sender draggingPasteboard];
    assert( pb != 0 );
    char const* type = [[pb availableTypeFromArray:[NSArray arrayWithObject:[NSString stringWithCString:CLUE_CARD_PBTYPE]]] cString];
    assert( type != 0 );

    char* p;
    int len;
#error StreamConversion: 'dataForType:' (used to be 'readType:data:length:') returns an NSData instance
    &p = [pb dataForType:[NSString stringWithCString:CLUE_CARD_PBTYPE]];
    assert( len == sizeof(ClueCard) );
    ClueCard const piece = *((ClueCard const*) p);
#error StreamConversion: 'deallocatePasteboardData:length:' no longer exists and never needs to be called
    [pb deallocatePasteboardData:p length:len];

    ClueCoord const oldPos = [clueMgr pieceLocation:piece];
    [clueMgr movePiece:piece to:coord];

    [self displayAt:coord];

    id obj = client;
    client = 0;
    draggable = 0;
    map = 0;
    [obj piece:piece from:oldPos droppedAt:coord];

    return YES;
    }

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
    {
    
}


//-----------------------------------------------------------------------------
// allowDrag:map:for:
//-----------------------------------------------------------------------------
- (void) allowDrag:(bool const*)v map:(ClueMap const*)a_map for:(id)a_client
    {
    draggable = v;
    map = a_map;
    client = a_client;
    [[self window] makeKeyAndOrderFront:self];
    }

@end
