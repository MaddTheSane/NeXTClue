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
extern "Objective-C" {
#import <AppKit/NSText.h>
#import <AppKit/NSWindow.h>
#import <Foundation/NSBundle.h>
}
static char const RULES[] = "ClueRules";

@implementation ClueRules

//-----------------------------------------------------------------------------
// print:
//-----------------------------------------------------------------------------
#warning PrintingConversion:  printPSCode: has been renamed to print:.  Rename this method?
- (void)print:(id)sender
    {
    [text print:self];
}


//-----------------------------------------------------------------------------
// loadRules
//-----------------------------------------------------------------------------
- (void) loadRules
    {
    char buff[ FILENAME_MAX + 1 ];
    id const bundle = [NSBundle bundleForClass:[self class]];
#error StringConversion: This call to -[NXBundle getPath:forResource:ofType:] has been converted to the similar NSBundle method.  The conversion has been made assuming that the variable called buff will be changed into an (NSString *).  You must change the type of the variable called buff by hand.
    if (((buff = [bundle pathForResource:[NSString stringWithCString:RULES] ofType:@"rtf"]) == nil))
#error StringConversion: This call to -[NXBundle getPath:forResource:ofType:] has been converted to the similar NSBundle method.  The conversion has been made assuming that the variable called buff will be changed into an (NSString *).  You must change the type of the variable called buff by hand.
	 buff = [bundle pathForResource:[NSString stringWithCString:RULES] ofType:@"rtfd"];
    [text readRTFDFromFile:[NSString stringWithCString:buff]];
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
