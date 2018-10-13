//-----------------------------------------------------------------------------
// ClueRules.M
//
//	Window with scrollable text to display the rules of the game.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id$
// $Log$
//-----------------------------------------------------------------------------
#import "ClueRules.h"
#import	"ClueLoadNib.h"
extern "Objective-C" {
#import <appkit/Text.h>
#import <appkit/Window.h>
#import <objc/NXBundle.h>
}
static char const RULES[] = "ClueRules";

@implementation ClueRules

//-----------------------------------------------------------------------------
// print:
//-----------------------------------------------------------------------------
- (id) print:sender
    {
    [text printPSCode:self];
    return self;
    }


//-----------------------------------------------------------------------------
// loadRules
//-----------------------------------------------------------------------------
- (void) loadRules
    {
    char buff[ FILENAME_MAX + 1 ];
    id const bundle = [NXBundle bundleForClass:[self class]];
    if (![bundle getPath:buff forResource:RULES ofType:"rtf"])
	 [bundle getPath:buff forResource:RULES ofType:"rtfd"];
    [text openRTFDFrom:buff];
    }


//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------
- (id) init
    {
    [super init];
    ClueLoadNib( self );
    [self loadRules];
    [window setFrameAutosaveName:"ClueRules"];
    return self;
    }


//-----------------------------------------------------------------------------
// launch
//-----------------------------------------------------------------------------
- (void) launch
    {
    [window makeKeyAndOrderFront:self];
    }


//-----------------------------------------------------------------------------
// +launch
//-----------------------------------------------------------------------------
+ (void) launch
    {
    static ClueRules* obj = [[self alloc] init];
    [obj launch];
    }

@end
