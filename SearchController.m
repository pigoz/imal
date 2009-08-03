//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchController.h"
#import "MALHandler.h"
#import "SearchOperation.h"


@implementation SearchController

@synthesize __entries;

-(IBAction) search:(id)sender
{
	[spinner startAnimation:nil];
	[spinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * type = @"anime";
	if([[popupButton objectValue] intValue]==1)
		type = @"manga";
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:[searchField stringValue] withType:type controller:self]];
	
}
-(void) callback:(NSArray *) entries
{
	@synchronized(self){
		[self willChangeValueForKey:@"__entries"];
		[__entries release];
		__entries = [entries retain];
		[self didChangeValueForKey:@"__entries"];
		[spinner stopAnimation:nil];
		[spinner setHidden:YES];
	}
}

@end
