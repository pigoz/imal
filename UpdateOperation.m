//
//  UpdateOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "UpdateOperation.h"
#import "MALHandler.h"
#import "PGZCallback.h"
#import "Entry.h"

@implementation UpdateOperation

@synthesize __entry;
@synthesize __values;
@synthesize __callback;

-(UpdateOperation *) initWithEntry:(Entry *) entry values:(NSMutableDictionary*) values callback:(PGZCallback *) callback
{
	self = [super init];
	if (self != nil) {
		self.__entry = entry;
		self.__values = values;
		self.__callback = callback;
	}
	return self;
}

-(void)main
{
	MALHandler * mal = [MALHandler sharedHandler];
	
	// Building XML data
	NSXMLElement *entry = (NSXMLElement *)[NSXMLNode elementWithName:@"entry"];
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithRootElement:entry];
	[xml setVersion:@"1.0"];
	[xml setCharacterEncoding:@"UTF-8"];
	for(NSString * _k in self.__values){
		[entry addChild:[NSXMLNode elementWithName:_k stringValue:[self.__values objectForKey:_k]]];
	}
	NSData *xmldata = [xml XMLDataWithOptions:NSXMLDocumentTidyXML];
	
	// Decide to increase rewatched value
	if([[[self.__entry entity] name] isEqual:@"anime"]){
		if([[__entry valueForKey:@"my_rewatching"] boolValue] && 
		   [[__entry valueForKey:@"my_episodes"] intValue] == [[__entry valueForKey:@"episodes"] intValue])
			[mal increaseRewatchedValue:[[__entry valueForKey:@"my_id"] intValue] anime_id:[[__entry valueForKey:@"id"] intValue]];
	}
	
	// Send post request
	NSString * resource = [NSString stringWithFormat:@"/%@list/update/%d.xml", [[__entry entity] name], [[__entry valueForKey:@"id"] intValue]];
	NSString * xmlstr = [[[NSString alloc] initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease];
	xmldata = [[NSString stringWithFormat:@"data=%@", xmlstr] dataUsingEncoding:NSUTF8StringEncoding];
	[mal post:resource data:xmldata];
	[self.__callback perform];
	[xml release];
}

@end
