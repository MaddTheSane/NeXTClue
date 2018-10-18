//-----------------------------------------------------------------------------
// ClueTrace.M
//
//	This object manages a Text object, formatting and appending standard
//	Clue messages.
//
// Copyright (C), 1997, Paul McCarthy.  All rights reserved.
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// $Id: ClueTrace.M,v 1.2 97/06/27 08:52:02 zarnuk Exp $
// $Log:	ClueTrace.M,v $
//  Revision 1.2  97/06/27  08:52:02  zarnuk
//  v23 -- reversed the order of name+icon pairs.  Icons now come
//  after the name.
//  
//  Revision 1.1  97/05/31  10:13:04  zarnuk
//  v21
//  
//-----------------------------------------------------------------------------
#import "ClueTrace.h"
#import	"ClueLoadNib.h"
#import <AppKit/NSText.h>
#import <AppKit/NSCell.h>
#import <AppKit/AppKit.h>

extern "C" {
#import <stdio.h>
}


@implementation ClueTrace

//-----------------------------------------------------------------------------
// initText:
//-----------------------------------------------------------------------------
- initWithText:(NSText*)obj
{
    self = [super init];
    text = obj;
    return self;
}


//-----------------------------------------------------------------------------
// appendText:
//-----------------------------------------------------------------------------
- (void) appendText:(NSString*)s
{
    NSInteger const n = [[text string] length];
    [text setSelectedRange:NSMakeRange(n, 0)];
    [text replaceCharactersInRange:NSMakeRange(n, 0) withString:s];
}

- (void) appendIcon:(NSString*)s
{
    NSTextAttachmentCell* cell = [[NSTextAttachmentCell alloc] initImageCell:[NSImage imageNamed:s]];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: cell ];
    NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attachment];
    [cell release];
    [attachment release];
    NSData *ourData = [attrStr RTFDFromRange:NSMakeRange(0, attrStr.length) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType}];
    NSInteger const n = [[text string] length];
    [text setSelectedRange:NSMakeRange(n, 0)];
    [text replaceCharactersInRange:NSMakeRange(n, 0) withRTFD:ourData];
}

- (void) appendPiece:(ClueCard)x
{
    NSString *s = @(ClueCardName(x));
    [self appendText:@" "];
    [self appendText:s];
    [self appendText:@" "];
    [self appendIcon:s];
    [self appendText:@"  "];
}


- (void) fancyPlayer:(int)player action:(NSString*)action
            solution:(ClueSolution const*)x
{
    [self appendText:[NSString stringWithFormat:@"player %d %@: ", player+1, action]];
    for (int i = 0; i < CLUE_CATEGORY_COUNT; i++)
        [self appendPiece:x->v[i]];
}

- (void) player:(int)playerID accuses:(ClueSolution const*)x wins:(BOOL)wins
{
    [self fancyPlayer:playerID action:@"accuses" solution:x];
    [self appendText:(wins ? @"and wins.\n\n" : @"and loses.\n\n")];
    [text scrollRangeToVisible:[text selectedRange]];
}

- (void) player:(int)playerID suggests:(ClueSolution const*)x
{
    [self fancyPlayer:playerID action:@"suggests" solution:x];
    [self appendText:@"\n"];
}

- (char const*) format:(ClueSolution const*)x
{
    static char buff[256];
    sprintf( buff, "%s %s %s",
            ClueCardName(x->suspect()),
            ClueCardName(x->weapon()),
            ClueCardName(x->room()) );
    return buff;
}

- (void) message:(NSString*)msg solution:(ClueSolution const*)x
{
    [self appendText:[NSString stringWithFormat:@"%@: %s\n", msg, [self format:x]]];
}

- (void) player:(int)playerID action:(NSString*)a
       solution:(ClueSolution const*)x
{
    [self message:[NSString stringWithFormat:@"player %d %@", playerID + 1, a] solution:x];
}

- (void) player:(int)playerID cannotDisprove:(ClueSolution const*)x
{
    [self player:playerID action:@"cannot disprove" solution:x];
}

- (void) player:(int)playerID disproves:(ClueSolution const*)x
{
    [self player:playerID action:@"disproves" solution:x];
    [self appendText:@"\n"];
    [text scrollRangeToVisible:[text selectedRange]];
}


- (void) nobodyDisproves:(ClueSolution const*)x
{
    [self message:@"nobody disproves" solution:x];
    [self appendText:@"\n"];
    [text scrollRangeToVisible:[text selectedRange]];
}


- (void) player:(int)p reveals:(ClueCard)card
{
    [self appendText:[NSString stringWithFormat:@"player %d reveals ", p+1]];
    [self appendPiece:card];
    [self appendText:@"\n\n"];
    [text scrollRangeToVisible:[text selectedRange]];
}


- (void) newGameNumPlayers:(int)n
{
    [self appendText:[NSString stringWithFormat:@"New game: %d players.\n", n]];
}


- (void) player:(int)p piece:(ClueCard)c name:(NSString*)s numCards:(int)n
{
    [self appendText:[NSString stringWithFormat:@"player %d: %@, %d cards, piece: ", p+1, s, n]];
    [self appendPiece:c];
    [self appendText:@"\n"];
}


- (void) player:(int)p num:(int)n cards:(ClueCard const*)cards
{
    [self appendText:[NSString stringWithFormat:@"\nplayer %d: hand: ", p+1]];
    for (int i = 0; i < n; i++)
        [self appendPiece:cards[i]];
    [self appendText:@"\n\n"];
    [text scrollRangeToVisible:[text selectedRange]];
}

@end
