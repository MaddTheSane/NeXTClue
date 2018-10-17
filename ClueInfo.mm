//-----------------------------------------------------------------------------
// ClueInfo.M
//
//	Info panel for the Clue program.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueInfo.M,v 1.5 97/07/09 23:29:52 zarnuk Exp $
// $Log:	ClueInfo.M,v $
//  Revision 1.5  97/07/09  23:29:52  zarnuk
//  v24 -- Fixed bug: format:field:file: was always setting buildField.
//  
//  Revision 1.4  97/06/27  10:39:47  zarnuk
//  v23 -- Added releaseField.
//  
//  Revision 1.3  97/05/31  16:15:03  zarnuk
//  Makes key so that cmd-w will close the window.
//-----------------------------------------------------------------------------
#import "ClueInfo.h"
#import "ClueLoadNib.h"

extern "Objective-C" {
#import	<AppKit/NSTextField.h>
#import	<AppKit/NSPanel.h>
#import	<Foundation/NSBundle.h>
}

extern "C" {
#import	<stdio.h>		// FILENAME_MAX, fopen(), etc.
#import	<stdlib.h>		// exit()
}


@implementation ClueInfo

//-----------------------------------------------------------------------------
// format:field:file:
//-----------------------------------------------------------------------------
- (void) format:(char const*)fmt field:(NSTextField*)fld file:(char const*)file
    {
    char path[ FILENAME_MAX ];
    char write_buff[ 256 ];

    char const* ver = "find?";

#error StringConversion: This call to -[NXBundle getPath:forResource:ofType:] has been converted to the similar NSBundle method.  The conversion has been made assuming that the variable called path will be changed into an (NSString *).  You must change the type of the variable called path by hand.
    if (path = [[NSBundle mainBundle] pathForResource:[NSString stringWithCString:file] ofType:@""])
	{
	FILE* fp;
	if ((fp = fopen( path, "r" )) != 0)
	    {
	    char read_buff[ 256 ];
	    if (fscanf( fp, "%s", read_buff ) == 1)
		{
		sprintf( write_buff, fmt, read_buff );
		ver = write_buff;
		}
	    else
		ver = "parse?";
	    fclose( fp );
	    }
	else
	    ver = "open?";
	}

    [fld setStringValue:[NSString stringWithCString:ver]];
    }


//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------
- (id) init
    {
    [super init];
    ClueLoadNib( self );

    [self format:"Release %s" field:releaseField file:"RELEASE_NUMBER"];
    [self format:"Build %s" field:buildField file:"PACKAGE_NUMBER"];

    return self;
    }


//-----------------------------------------------------------------------------
// makeKeyAndOrderFront:
//-----------------------------------------------------------------------------
- (void)makeKeyAndOrderFront:(id)sender
    {
    [window makeKeyAndOrderFront:sender];
    return window;
    }


//-----------------------------------------------------------------------------
// +launch
//-----------------------------------------------------------------------------
+ (id) launch
    {
    static ClueInfo* instance = 0;
    if (instance == 0)
	instance = [[self alloc] init];
    [instance makeKeyAndOrderFront:self];
    return self;
    }

@end
