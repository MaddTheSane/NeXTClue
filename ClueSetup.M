//-----------------------------------------------------------------------------
// ClueSetup.M
//
//	User preferences module for the Clue game.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueSetup.M,v 1.1 97/05/31 10:12:38 zarnuk Exp $
// $Log:	ClueSetup.M,v $
//  Revision 1.1  97/05/31  10:12:38  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueSetup.h"
#import	"ClueButton.h"
#import	"ClueLoadNib.h"

#import "ClueAnnaLyzer.h"
#import "ClueBeaGinner.h"
#import	"ClueCyBorg.h"
#import	"ClueCyLent.h"
#import "ClueDeeDucer.h"
#import	"ClueHuman.h"
#import "ClueRandyMizer.h"

extern "Objective-C" {
#import <Foundation/NSUserDefaults.h>
#import	<AppKit/NSApplication.h>
#import	<AppKit/NSPanel.h>
}

enum	{
	CHOICE_NOT_PLAYING,
	CHOICE_HUMAN,
	CHOICE_CY_LENT,
	CHOICE_RANDY_MIZER,
	CHOICE_BEA_GINNER,
	CHOICE_ANNA_LYZER,
	CHOICE_DEE_DUCER,
	CHOICE_CY_BORG,
	CHOICE_MAX
	};

static id CHOICES[ CHOICE_MAX ];

static int NUM_PLAYERS = 0;
static id PLAYER_CLASS[ CLUE_NUM_PLAYERS_MAX ];
static ClueCard PLAYER_PIECE[ CLUE_NUM_PLAYERS_MAX ];
static int PIECE_CHOICE[ CLUE_NUM_PLAYERS_MAX ];


static char const DEF_OWNER[] = "Clue";
static char const DEF_NAME[] = "ClueSetup";

int const CANCEL_PRESSED	= 0;
int const OK_PRESSED		= 1;



@implementation ClueSetup

//-----------------------------------------------------------------------------
// QUERY INTERFACE
//-----------------------------------------------------------------------------
+ (int) numPlayers			{ return NUM_PLAYERS; }
+ (ClueCard) playerPiece:(int)n		{ return PLAYER_PIECE[n]; }
+ (id) playerClass:(int)n		{ return PLAYER_CLASS[n]; }


//-----------------------------------------------------------------------------
// +initChoices
//-----------------------------------------------------------------------------
+ (void) initChoices
    {
    CHOICES[ CHOICE_NOT_PLAYING ]	= 0;
    CHOICES[ CHOICE_HUMAN ]		= [ClueHuman class];
    CHOICES[ CHOICE_CY_LENT ]		= [ClueCyLent class];
    CHOICES[ CHOICE_RANDY_MIZER ]	= [ClueRandyMizer class];
    CHOICES[ CHOICE_BEA_GINNER ]	= [ClueBeaGinner class];
    CHOICES[ CHOICE_ANNA_LYZER ]	= [ClueAnnaLyzer class];
    CHOICES[ CHOICE_DEE_DUCER ]		= [ClueDeeDucer class];
    CHOICES[ CHOICE_CY_BORG ]		= [ClueCyBorg class];
    }


//-----------------------------------------------------------------------------
// +getDefaults
//-----------------------------------------------------------------------------
+ (void) getDefaults
    {
    BOOL ok = NO;
    int v[ 6 ];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEF_OWNER.  If the owner was different from your applications name, you may need to modify this code.
    char const* s = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithCString:DEF_NAME]] cString];

    if (s != 0 &&
	sscanf( s, "%d %d %d %d %d %d", v+0,v+1,v+2,v+3,v+4,v+5 ) == 6)
	{
	ok = YES;
	int n = 0;
	for (int i = 0; i < 6; i++)
	    if (v[i] < 0 || CHOICE_MAX <= v[i])
		{ ok = NO; break; }
	    else if (v[i] > 0)
		n++;
	if (n < CLUE_NUM_PLAYERS_MIN)
	    ok = NO;
	}

    if (!ok)
	{
	v[0] = CHOICE_HUMAN;
	v[1] = CHOICE_RANDY_MIZER;
	v[2] = CHOICE_RANDY_MIZER;
	v[3] = CHOICE_RANDY_MIZER;
	v[4] = CHOICE_RANDY_MIZER;
	v[5] = CHOICE_RANDY_MIZER;
	}

    for (int j = 0; j < 6; j++)
	{
	int const x = v[j];
	PIECE_CHOICE[ j ] = x;
	if (x != 0)
	    {
	    PLAYER_CLASS[ NUM_PLAYERS ] = CHOICES[ x ];
	    PLAYER_PIECE[ NUM_PLAYERS ] = ClueCard( j );
	    NUM_PLAYERS++;
	    }
	}
    }


//-----------------------------------------------------------------------------
// +initialize
//-----------------------------------------------------------------------------
+ (void)initialize
    {
    if (self == [ClueSetup class])
	{
	[self initChoices];
	[self getDefaults];
	}
    return;
    }


//-----------------------------------------------------------------------------
// revert
//-----------------------------------------------------------------------------
- (void) revert
    {
    for (int i = 0; i < 6; i++)
	[pops[i] selectTag:PIECE_CHOICE[i]];
    }


//-----------------------------------------------------------------------------
// revertPressed:
//-----------------------------------------------------------------------------
- revertPressed:sender
    {
    [self revert];
    [window display];
    return self;
    }


//-----------------------------------------------------------------------------
// okPressed:
//-----------------------------------------------------------------------------
- okPressed:sender
    {
    int v[ 6 ];

    int n = 0;
    for (int i = 0; i < 6; i++)
	{
	int const x = [pops[i] selectedTag];
	v[i] = x;
	if (x != 0)
	    n++;
	}

    if (n < CLUE_NUM_PLAYERS_MIN)
	{
	NSRunAlertPanel(@"Too Few", @"There must be at least %d active players.", @"OK", nil, nil, CLUE_NUM_PLAYERS_MIN);
	}
    else
	{
	NUM_PLAYERS = 0;
	for (int i = 0; i < 6; i++)
	    {
	    int const x = v[i];
	    PIECE_CHOICE[i] = x;
	    if (x != 0)
		{
		PLAYER_CLASS[ NUM_PLAYERS ] = CHOICES[ x ];
		PLAYER_PIECE[ NUM_PLAYERS ] = ClueCard( i );
		NUM_PLAYERS++;
		}
	    }
	char buff[ 64 ];
	sprintf( buff, "%d %d %d %d %d %d", v[0],v[1],v[2],v[3],v[4],v[5] );
#warning DefaultsConversion: [<NSUserDefaults> setObject:...forKey:...] used to be NXWriteDefault(DEF_OWNER, DEF_NAME, buff). Defaults will be synchronized within 30 seconds after this change.  For immediate synchronization, call '-synchronize'. Also note that the first argument of NXWriteDefault is now ignored; to write into a domain other than the apps default, see the NSUserDefaults API.
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:buff] forKey:[NSString stringWithCString:DEF_NAME]];
	[NSApp stopModalWithCode:OK_PRESSED];
	}

    return self;
    }


//-----------------------------------------------------------------------------
// cancelPressed:
//-----------------------------------------------------------------------------
- cancelPressed:sender
    {
    [NSApp stopModalWithCode:CANCEL_PRESSED];
    return self;
    }


//-----------------------------------------------------------------------------
// startNewGame
//-----------------------------------------------------------------------------
- (BOOL) startNewGame
    {
    [self revert];
    [window makeKeyAndOrderFront:self];
    int const rc = [NSApp runModalForWindow:window];
    [window close];
    return rc == OK_PRESSED;
    }


//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------
- init
    {
    [super init];
    ClueLoadNib( self );
    pops[0] = scarletPop;
    pops[1] = mustardPop;
    pops[2] = whitePop;
    pops[3] = greenPop;
    pops[4] = peacockPop;
    pops[5] = plumPop;
    return self;
    }


//-----------------------------------------------------------------------------
// +startNewGame
//-----------------------------------------------------------------------------
+ (BOOL) startNewGame
    {
    static ClueSetup* instance = [[self alloc] init];
    return [instance startNewGame];
    }

@end
