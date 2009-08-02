//
//  SearchController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchController : NSObject {
	NSArray * __entryNodes;
}

-(IBAction) search:(NSString *) query;
-(void) returnArray:(NSArray *) returnArray;

@end
