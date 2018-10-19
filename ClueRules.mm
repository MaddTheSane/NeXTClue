//-----------------------------------------------------------------------------
// ClueRules.M
//
//	Window with scrollable text to display the rules of the game.
//
// Copyright (C), 1997, Paul McCarthy and Eric Sunshine.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueRules.M,v 1.1 97/05/31 10:11:51 zarnuk Exp $
// $Log:	ClueRules.M,v $
//  Revision 1.1  97/05/31  10:11:51  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueRules.h"
#import	"ClueLoadNib.h"
#import <AppKit/NSText.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSWindow.h>
#import <Foundation/NSBundle.h>

static NSString * const RULES = @"ClueRules";

@implementation ClueRules

//-----------------------------------------------------------------------------
// print:
//-----------------------------------------------------------------------------
- (void)print:(id)sender
{
    [text print:self];
}


//-----------------------------------------------------------------------------
// loadRules
//-----------------------------------------------------------------------------
- (void) loadRules
{
    NSString *buff;
    id const bundle = [NSBundle bundleForClass:[self class]];
    if ((buff = [bundle pathForResource:RULES ofType:@"rtf"]) == nil)
        buff = [bundle pathForResource:RULES ofType:@"rtfd"];
    [text readRTFDFromFile:buff];
}


//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------
- (id) init
{
    [super init];
    ClueLoadNib( self );
    [self loadRules];
    [window setFrameAutosaveName:@"ClueRules"];
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
