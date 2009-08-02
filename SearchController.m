//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchController.h"
#import "MALHandler.h"
#import "SearchOperation.h"


@implementation SearchController

-(IBAction) search:(NSString *) query
{
	MALHandler * mal = [MALHandler sharedHandler];
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:query withType:@"anime" callback:@selector(returnArray:)]];
	
}

-(void) returnArray:(NSArray *) returnArray
{
}

@end
