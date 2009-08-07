//
//  PGZFilterView.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/7/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "PGZFilterView.h"


@implementation PGZFilterView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
	CGFloat c = 232.0/255.0;
	[[NSColor colorWithCalibratedRed:c green:c blue:c alpha:1.0] set];
	[NSBezierPath fillRect:bounds];
}

@end
