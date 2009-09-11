//
//  Trigram.m
//  iMAL
//
//  Created by Stefano Pigozzi on 9/10/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "Trigram.h"


@implementation Trigram

@synthesize trigram, title, score, anime_id;

DECLARE_PROPERTIES(
				   DECLARE_PROPERTY(@"trigram", @"@\"NSString\""),
				   DECLARE_PROPERTY(@"title", @"@\"NSString\""),
				   DECLARE_PROPERTY(@"score", @"@\"int\""),
				   DECLARE_PROPERTY(@"anime_id", @"@\"int\"")
)

/// need to query only on the trigram names
+ (NSArray *) indices
{
	NSArray * index1 = [NSArray arrayWithObject:@"trigram"];
	return [NSArray arrayWithObjects:index1, nil];
}

- (void)dealloc
{
	[trigram release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<Trigram.%d %@>", [self pk], trigram];
}

@end
