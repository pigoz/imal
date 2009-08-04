//
//  SearchOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchOperation.h"
#import "MALHandler.h"
#import "SearchWindowController.h"
#import "SearchModel.h"
#import "NSXMLNode+stringForXPath.h"

@implementation SearchOperation

@synthesize __query;
@synthesize __type;
@synthesize __controller;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type controller:(SearchWindowController *) controller
{
	self = [super init];
	if (self != nil) {
		self.__query = query;
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
		NSArray * entryNodes = [doc nodesForXPath:[NSString stringWithFormat:@"%@/entry",__type] error:&error];
		NSMutableArray * searchModel = [[NSMutableArray alloc] init];
		for(NSXMLNode * n in entryNodes){
			SearchModel *s = [SearchModel new];
			s.__title = [n stringForXPath:@"title"];
			s.__type = [n stringForXPath:@"type"];
			s.__score = [[n stringForXPath:@"score"] floatValue];
			if([self.__type caseInsensitiveCompare:@"anime"]==0)
				s.__episodes = [[n stringForXPath:@"episodes"] intValue];
			else
				s.__episodes = [[n stringForXPath:@"chapters"] intValue];
			s.__image_url = [n stringForXPath:@"image"];
			s.__synonyms = [n stringForXPath:@"synonyms"];
			s.__status = [n stringForXPath:@"status"];
			s.__start_date = [n stringForXPath:@"start_date"];
			s.__end_date = [n stringForXPath:@"end_date"];
			s.__synopsis = [n stringForXPath:@"synopsis"];
			[searchModel addObject:[s autorelease]];
		}
		[__controller callback:[searchModel autorelease]]; // callback on the controller
	}
}

@end
