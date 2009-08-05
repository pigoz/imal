//
//  AddOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/5/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AddOperation.h"
#import "PGZCallback.h"
#import "MALHandler.h"

@implementation AddOperation

@synthesize __id;
@synthesize __type;
@synthesize __values;
@synthesize __callback;

-(AddOperation *) initWithID:(int) entryID withType:(NSString *) type values:(NSMutableDictionary*) values callback:(PGZCallback *) callback
{
	self = [super init];
	if (self != nil) {
		self.__id = entryID;
		self.__type = type;
		self.__values = values;
		self.__callback = callback;
	}
	return self;
}

-(void)main
{
	// Building XML data
	NSXMLElement *entry = (NSXMLElement *)[NSXMLNode elementWithName:@"entry"];
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithRootElement:entry];
	[xml setVersion:@"1.0"];
	[xml setCharacterEncoding:@"UTF-8"];
	for(NSString * _k in self.__values){
		[entry addChild:[NSXMLNode elementWithName:_k stringValue:[self.__values objectForKey:_k]]];
	}
	NSData *xmldata = [xml XMLDataWithOptions:NSXMLDocumentTidyXML];
	
	// Send post request
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * resource = [NSString stringWithFormat:@"/%@list/add/%d.xml", self.__type, self.__id];
	NSString * xmlstr = [[[NSString alloc] initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease];
	xmldata = [[NSString stringWithFormat:@"data=%@", xmlstr] dataUsingEncoding:NSUTF8StringEncoding];
	
	[mal post:resource data:xmldata];
	[self.__callback perform];
	[xml release];
}

@end
