//
//  SearchOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SearchController;

@interface SearchOperation : NSOperation {

	NSString * __query;
	NSString * __type;
	SearchController * __controller;
	
}

@property (retain) NSString * __query;
@property (retain) NSString * __type;
@property (retain) SearchController * __controller;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type controller:(SearchController *) controller;

@end
