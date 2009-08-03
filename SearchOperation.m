//
//  SearchOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchOperation.h"
#import "MALHandler.h"
#import "SearchController.h"


@implementation SearchOperation

@synthesize __query;
@synthesize __type;
@synthesize __controller;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type controller:(SearchController *) controller
{
	self = [super init];
	if (self != nil) {
		self.__query = query;
		NSLog(self.__query);
		self.__type = type;
		self.__controller = controller;
	}
	return self;
}

-(void)main
{
	MALHandler * mal = [MALHandler sharedHandler];
	NSData * _result = [mal search:self.__query type:self.__type];
	if(_result != nil){ // recived something
		NSError* error;
		NSXMLDocument * doc = [[NSXMLDocument alloc] initWithData:_result options:NSXMLDocumentTidyXML error:&error];
		NSArray * entryNodes = [doc nodesForXPath:@"anime/entry" error:&error];
		[__controller callback:entryNodes]; // callback on the controller
	}
}

@end
