//
//  SearchOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchOperation.h"
#import "MALHandler.h"


@implementation SearchOperation

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type callback:(SEL)callback
{
	self = [super init];
	if (self != nil) {
		self->__query = query;
		self->__type = type;
		self->__callback = callback;
	}
	return self;
}

-(void)main
{
	MALHandler * mal = [MALHandler sharedHandler];
	NSData * _result = [mal search:self->__query type:self->__type];
	if(_result != nil){ // recived something
		NSError* error;
		NSXMLDocument * doc = [[NSXMLDocument alloc] initWithData:_result options:0 error:&error];
		NSArray * entryNodes = [doc nodesForXPath:@"anime/entry" error:&error];
		[self performSelector:__callback withObject:[entryNodes autorelease]]; // callback on the controller
		[doc release];
	}
}

@end
