//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/4/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchController.h"
#import "SearchWindowController.h"


@implementation SearchController

-(IBAction) showSearchWindow:(id)sender
{
	@synchronized(self){
		if(!searchWindowController){
			searchWindowController = [[SearchWindowController alloc] init];
		}
	}
	[searchWindowController showWindow:self];
}

@end
