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
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueBoardView.h"
#import "ClueCoordArray.h"
#import	"ClueMap.h"
#import "ClueMgr.h"
extern "Objective-C" {
#import <appkit/Application.h>
#import <appkit/NXImage.h>
}
extern "C" {
#import <assert.h>
#import <string.h>	// memset()
#import <dpsclient/psops.h>
}

static char const* const BOARD_IMAGE = "board";
int const TILE_SIZE = 20;

struct CL_RegionRel
	{
	int width;
	int height;
	NXImage* image;
	};

struct CL_RegionAbs
	{
	ClueCoord origin;
	CL_RegionRel* region;
	int region_id;
	};

static CL_RegionAbs REGIONS[ CLUE_ROW_MAX ][ CLUE_COL_MAX ];

static inline float absval( float x ) { return (x < 0 ? -x : x ); }
static inline BOOL isSlop( NXEvent const* e1, NXEvent const* e2,
			   float const slop )
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

    NXRect r = {{ 0, 0 }, { TILE_SIZE, TILE_SIZE }};
    NXImage* unit_image = [[NXImage alloc] initSize:&r.size];
    [unit_image lockFocus];
    NXSetColor( NXConvertRGBAToColor(0,0,1,0.5) );
//      NXSetColor( NXConvertRGBAToColor(0,1,0,0.40) );
    NXRectFill( &r );
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
		    NXImage* image = [[NXImage alloc] initSize:&r.size];

		    CL_RegionRel* region = new CL_RegionRel;
		    region->width = width;
		    region->height = height;
		    region->image = image;

		    [image lockFocus];
		    NXSetColor( NX_COLORCLEAR );
		    NXRectFill( &r );
		    for (k = 0; k < n; k++)
			{
			coord = list[k];
			int row_origin = height + row_min - coord.row - 1;
			int col_origin = coord.col - col_min;
			NXPoint const pt = { col_origin * TILE_SIZE,
					     row_origin * TILE_SIZE };
			[unit_image composite:NX_COPY toPoint:&pt];

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

+ (id)initialize
    {
    if (self == [ClueBoardView class])
	[self initRegions];
    return self;
    }

- (id)initFrame:(NXRect const*)rect
    {
    [super initFrame:rect];
    [self setClipping:NO];
    [self setOpaque:YES];
    [self registerForDraggedTypes:&CLUE_CARD_PBTYPE count:1];
    background = [NXImage findImageNamed:BOARD_IMAGE];
    for (int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	pieces[i] = [NXImage findImageNamed:ClueCardName(ClueCard(i))];
    dragging = NO;
    fade = [[NXImage allocFromZone:[self zone]] init];
    return self;
    }

- (id)free
    {
    // Don't free 'background' or 'pieces; -- they are shared/named images.
    [self unregisterDraggedTypes];
    [fade free];
    return [super free];
    }

- (BOOL)acceptsFirstMouse
    {
    return YES;
    }

- (NXPoint)pointAtCoord:(ClueCoord)coord
    {
    NXPoint p;
    p.x = coord.col * TILE_SIZE;
    p.y = (CLUE_ROW_MAX - coord.row - 1) * TILE_SIZE;
    return p;
    }

- (NXRect)rectAtCoord:(ClueCoord)coord
    {
    NXRect r;
    r.origin = [self pointAtCoord:coord];
    r.size.width = TILE_SIZE;
    r.size.height = TILE_SIZE;
    return r;
    }

- (void)displayAt:(ClueCoord)coord
    {
    NXRect const r = [self rectAtCoord:coord];
    [self display:&r:1];
    }

// *NOTE*
// The board image is actually 1 pixel wider and higher than it needs to be
// to contain the grid (the extra pixel is used for a black border), hence
// the conditionals.
- (ClueCoord)coordAtPoint:(NXPoint)pt
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

- (NXPoint)originAtCoord:(ClueCoord)coord forSize:(NXSize)size
    {
    assert( size.width < TILE_SIZE );
    assert( size.height < TILE_SIZE );
    NXRect r = [self rectAtCoord:coord];
    NXPoint p;
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

- (void)drawPieces:(NXRect const*)draw_rect
    {
    for (int i = 0; i < CLUE_SUSPECT_COUNT + CLUE_WEAPON_COUNT; i++)
	{
	ClueCoord const coord = [clueMgr pieceLocation:(ClueCard)i];
	NXRect const r = [self rectAtCoord:coord];
	if (NXIntersectsRect( draw_rect, &r ))
	    {
	    NXSize s; [pieces[i] getSize:&s];
	    NXPoint const p = [self originAtCoord:coord forSize:s];
	    if (dragging &&
		dragSource.row == coord.row && dragSource.col == coord.col)
		[fade composite:NX_SOVER toPoint:&p];
	    else
		[pieces[i] composite:NX_SOVER toPoint:&p];
	    }
	}
    }

- (id)drawSelf:(NXRect const*)rects :(int)nrects
    {
    [background composite:NX_COPY fromRect:rects toPoint:&rects->origin];
    [self drawPieces:rects];
    return self;
    }

- (void)setClueMgr:(ClueMgr*)p
    {
    clueMgr = p;
    }

- (NXDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
    {
    return NX_DragOperationGeneric;
    }

- (BOOL)ignoreModifierKeysWhileDragging
    {
    return YES;
    }

- (void)fadeOut:(NXImage*)i at:(ClueCoord)coord
    {
    dragging = YES;
    dragSource = coord;

    NXSize s; [i getSize:&s];
    [fade setSize:&s];

    [fade lockFocus];
    NXRect r = {{ 0, 0 }, { s.width, s.height }};
    NXSetColor( NXConvertRGBAToColor(1,1,1,0.5) );
    NXRectFill( &r );
    NXPoint const zero = {0,0};
    [i composite:NX_DATOP toPoint:&zero];
    [fade unlockFocus];
    r = [self rectAtCoord:coord];
    [self display:&r:1];
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
    [window flushWindow];
    }


- (void)performDrag:(NXEvent*)downEvent at:(ClueCoord)coord
    dragEvent:(NXEvent*)dragEvent
    {
    ClueCard const piece = [self pieceAtCoord:coord];
    assert( piece < CLUE_CARD_MAX );
    NXImage* const i = pieces[ piece ];
    NXSize s; [i getSize:&s];
    NXPoint origin = [self originAtCoord:coord forSize:s];
    NXPoint offset = {0,0};
    if (dragEvent != 0 && dragEvent->type == NX_MOUSEDRAGGED)
	{
	offset.x = dragEvent->location.x - downEvent->location.x;
	offset.y = dragEvent->location.y - downEvent->location.y;
	}
    
    Pasteboard* pb = [Pasteboard newName:NXDragPboard];
    [pb declareTypes:&CLUE_CARD_PBTYPE num:1 owner:0];
    [pb writeType:CLUE_CARD_PBTYPE data:(char const*)&piece
		length:sizeof(piece)];
    
    [self fadeOut:i at:coord];
    [self dragImage:i at:&origin offset:&offset
		event:downEvent pasteboard:pb source:self slideBack:YES];
    [self fadeInAt:coord];
    }

- (void)awaitDrag:(NXEvent*)p at:(ClueCoord)coord
    {
    float const DELAY = 0.25;
    float const SLOP = 4.0;
    int const WANTED = (NX_MOUSEUPMASK | NX_MOUSEDRAGGEDMASK);

    NXEvent mouseDown = *p;
    NXEvent* event;
    NXEvent peeker;
    int oldMask = [[self window] addToEventMask:WANTED];

    do	{
	event = [NXApp peekNextEvent:WANTED into:&peeker waitFor:DELAY
		threshold:NX_MODALRESPTHRESHOLD];
	if (event != 0 && event->type == NX_MOUSEDRAGGED)
	    event = [NXApp getNextEvent:NX_MOUSEDRAGGEDMASK];
	} while (event != 0 && event->type == NX_MOUSEDRAGGED && 
		isSlop( event, &mouseDown, SLOP ));

    [[self window] setEventMask:oldMask];

    if (event == 0 || event->type == NX_MOUSEDRAGGED)
	[self performDrag:&mouseDown at:coord dragEvent:event];
    }

- (BOOL)canPerformDrag:(NXEvent const*)p at:(ClueCoord)coord
    {
    ClueCard const piece = [self pieceAtCoord:coord];
    return piece < CLUE_CARD_MAX && draggable != 0 && draggable[piece];
    }

- (id) mouseDown:(NXEvent*)ev
    {
    NXPoint pt = ev->location;
    [self convertPoint:&pt fromView:0];
    ClueCoord const coord = [self coordAtPoint:pt];
    if ([self canPerformDrag:ev at:coord])
	[self awaitDrag:ev at:coord];
    return self;
    }

- (void)unhighlight
    {
    if (highlighting)
	{
	highlighting = NO;
	CL_RegionAbs const& reg =
		REGIONS[highlightCoord.row][highlightCoord.col];
	NXRect r;
	r.origin = [self pointAtCoord:reg.origin];
	r.size.width = reg.region->width * TILE_SIZE;
	r.size.height = reg.region->height * TILE_SIZE;
	[self display:&r:1];
	}
    }

- (NXDragOperation)highlightUnder:(id<NXDraggingInfo>)sender
    {
    NXPoint pt = [sender draggingLocation];
    [self convertPoint:&pt fromView:0];
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
	    NXPoint pt = [self pointAtCoord:r.origin];
	    [self lockFocus];
	    [r.region->image composite:NX_SOVER toPoint:&pt];
	    [self unlockFocus];
	    [[self window] flushWindow];
	    }
	}

    return (ok ? NX_DragOperationGeneric : NX_DragOperationNone);
    }

- (NXDragOperation)draggingEntered:(id<NXDraggingInfo>)sender
    {
    return [self highlightUnder:sender];
    }

- (id)draggingExited:(id <NXDraggingInfo>)sender
    {
    [self unhighlight];
    return self;
    }

- (NXDragOperation)draggingUpdated:(id<NXDraggingInfo>)sender
    {
    return [self highlightUnder:sender];
    }

- (BOOL)prepareForDragOperation:(id<NXDraggingInfo>)sender
    {
    [self unhighlight];
    return YES;
    }

- (BOOL)performDragOperation:(id<NXDraggingInfo>)sender
    {
    NXPoint pt = [sender draggingLocation];
    [self convertPoint:&pt fromView:0];
    ClueCoord const coord = [self coordAtPoint:pt];

    Pasteboard* pb = [sender draggingPasteboard];
    assert( pb != 0 );
    char const* type = [pb findAvailableTypeFrom:&CLUE_CARD_PBTYPE num:1];
    assert( type != 0 );

    char* p;
    int len;
    [pb readType:CLUE_CARD_PBTYPE data:&p length:&len];
    assert( len == sizeof(ClueCard) );
    ClueCard const piece = *((ClueCard const*) p);
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

- (id)concludeDragOperation:(id<NXDraggingInfo>)sender
    {
    return self;
    }


//-----------------------------------------------------------------------------
// allowDrag:map:for:
//-----------------------------------------------------------------------------
- (void) allowDrag:(bool const*)v map:(ClueMap const*)a_map for:(id)a_client
    {
    draggable = v;
    map = a_map;
    client = a_client;
    [window makeKeyAndOrderFront:self];
    }

@end
