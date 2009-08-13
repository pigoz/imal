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


//// helper method it converts a network based set of changes to data model one.
-(void)updateEntryWithCurrentValues
{
	for(NSString * _k in self.__values){
		if([_k isEqual:@"episode"] && 
		   ([[self.__values valueForKey:@"episode"] intValue] <= [[self.__entry valueForKey:@"episodes"] intValue] || 
			[[self.__entry valueForKey:@"episodes"] intValue] == 0)){
			[self.__entry setValue:[NSNumber numberWithInt:[[self.__values valueForKey:@"episode"] intValue]] forKey:@"my_episodes"];
		}
		if([_k isEqual:@"chapter"] && ([[self.__values valueForKey:@"chapter"] intValue] <= [[self.__entry valueForKey:@"chapters"] intValue] || 
		   [[self.__entry valueForKey:@"chapters"] intValue] == 0)){
			[self.__entry setValue:[NSNumber numberWithInt:[[self.__values valueForKey:@"chapter"] intValue]] forKey:@"my_chapters"];
		}
		if([_k isEqual:@"enable_rewatching"])
			[self.__entry setValue:[NSNumber numberWithInt:[[self.__values valueForKey:@"enable_rewatching"] intValue]] forKey:@"my_rewatching"];
		if([_k isEqual:@"status"])
			[self.__entry setValue:[NSNumber numberWithInt:[[self.__values valueForKey:@"status"] intValue]] forKey:@"my_status"];
		if([_k isEqual:@"score"])
			[self.__entry setValue:[NSNumber numberWithInt:[[self.__values valueForKey:@"score"] intValue]] forKey:@"score"];
	}
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
	
	// Send post request
	NSString * resource = [NSString stringWithFormat:@"/%@list/update/%d.xml", [[__entry entity] name], [[__entry valueForKey:@"id"] intValue]];
	NSString * xmlstr = [[[NSString alloc] initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease];
	xmldata = [[NSString stringWithFormat:@"data=%@", xmlstr] dataUsingEncoding:NSUTF8StringEncoding];
	NSData * resp_code = [mal post:resource data:xmldata];
	
	if([resp_code isMatchedByRegex:@"^Updated$"]){ // RegExKit ownz?
		BOOL will_increase_rewatched_value = NO; // will we or not?
		
		if([[[self.__entry entity] name] isEqual:@"anime"]){
			if([[__entry valueForKey:@"my_rewatching"] boolValue] &&
			   [[__entry valueForKey:@"my_episodes"] intValue] < [[__entry valueForKey:@"episodes"] intValue] && // editing same entry 2 times will do nothing
			   [[__values valueForKey:@"episode"] intValue] == [[__entry valueForKey:@"episodes"] intValue]) // we finished the episodes
				will_increase_rewatched_value = YES;
		} else {
			// TODO check rereading for manga
		}
		[self updateEntryWithCurrentValues]; // modify data model if network model was updated correctly
		
		if(will_increase_rewatched_value){
			[mal increaseRewatchedValue:[[__entry valueForKey:@"my_id"] intValue]// increases rewatched/reread values
							   anime_id:[[__entry valueForKey:@"id"] intValue]]; // this is not reflected on the local model
		}
	}
	
	[self.__callback perform];
	[xml release];
}

@end
