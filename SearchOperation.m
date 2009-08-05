//
//  SearchOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchOperation.h"
#import "MALHandler.h"
#import "SearchModel.h"
#import "NSXMLNode+stringForXPath.h"
#import "PGZCallback.h"

@implementation SearchOperation

@synthesize __query;
@synthesize __type;
@synthesize __callback;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type callback:(PGZCallback *) callback
{
	self = [super init];
	if (self != nil) {
		self.__query = query;
		self.__type = type;
		self.__callback = callback;
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
			SearchModel *s;
			if([self.__type caseInsensitiveCompare:@"anime"]==0)
				s = [[SearchModel alloc] initAnimeFromXMLNode:n];
			else
				s = [[SearchModel alloc] initMangaFromXMLNode:n];
			[searchModel addObject:[s autorelease]];
		}
		[__callback performWithObject:[searchModel autorelease]]; // callback on the controller
	}
}

@end
