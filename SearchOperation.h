//
//  SearchOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SearchWindowController;

@interface SearchOperation : NSOperation {

	NSString * __query;
	NSString * __type;
	SearchWindowController * __controller;
	
}

@property (retain) NSString * __query;
@property (retain) NSString * __type;
@property (retain) SearchWindowController * __controller;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type controller:(SearchWindowController *) controller;
-(NSString *)stringForPath:(NSString *)xp ofNode:(NSXMLNode *)n;

@end
