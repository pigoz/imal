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
#import "SearchModel.h"

@implementation SearchOperation

@synthesize __query;
@synthesize __type;
@synthesize __controller;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type controller:(SearchController *) controller
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
			s.__title = [self stringForPath:@"title" ofNode:n];
			s.__type = [self stringForPath:@"type" ofNode:n];
			s.__score = [[self stringForPath:@"score" ofNode:n] intValue];
			if([__type caseInsensitiveCompare:@"anime"]==0)
				s.__episodes = [[self stringForPath:@"episodes" ofNode:n] intValue];
			else
				s.__episodes = [[self stringForPath:@"chapters" ofNode:n] intValue];
			[searchModel addObject:[s autorelease]];
		}
		[__controller callback:[searchModel autorelease]]; // callback on the controller
	}
}

-(NSString *)stringForPath:(NSString *)xp ofNode:(NSXMLNode *)n
{
    NSError *error;
    NSArray *nodes = [n nodesForXPath:xp error:&error];
    if (!nodes) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        return nil;
    }
    if ([nodes count] == 0) {
        return nil;
    } else {
        return [[nodes objectAtIndex:0] stringValue];
    }
}

@end
