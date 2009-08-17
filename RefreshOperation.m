//
//  RefreshOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "RefreshOperation.h"
#import "MALHandler.h"
#import "NSXMLNode+stringForXPath.h"
#import "NSManagedObjectContext+PGZUtils.h"
#import "PGZCallback.h"
#import "Entry.h"

#import "IndexOperation.h"

@implementation RefreshOperation

@synthesize __type;
@synthesize __db;
@synthesize __start;
@synthesize __update;
@synthesize __done;


-(RefreshOperation *) initWithType:(NSString *) type context:(NSManagedObjectContext *) db  
							 start:(PGZCallback *) start update:(PGZCallback *)update done:(PGZCallback *) done
{
	self = [super init];
	if (self != nil) {
		self.__type = type;
		self.__db = db;
		self.__start = start;
		self.__update = update;
		self.__done = done;
	}
	return self;
}


-(void)main
{
	[__start perform];
	
	[__update performWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Refreshing %@list", self.__type],
																			@"title", @"downloading data from MAL", @"message", nil]];
	
	MALHandler * mal = [MALHandler sharedHandler];
	NSData * _result = [mal getList:self.__type];
	
	
	if(_result != nil){ // recived something
		[__update performWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Refreshing %@list", self.__type],
									  @"title", @"parsing XML data", @"message", nil]];
		NSError* error;
		NSXMLDocument * doc = [[NSXMLDocument alloc] initWithData:_result options:NSXMLDocumentTidyXML error:&error];
		NSArray * entryNodes = [doc nodesForXPath:[NSString stringWithFormat:@"myanimelist/%@",__type] error:&error];
		for(NSXMLNode * n in entryNodes){
			NSInteger __id = [[n stringForXPath:[NSString stringWithFormat:@"series_%@db_id", __type]] intValue];
			NSManagedObject * m = [__db fetchOrCreateEntityWithName:__type withID:__id];
			[m setValue:[n stringForXPath:@"series_title"] forKey:@"title"];
			[m setValue:[n stringForXPath:@"series_synonyms"] forKey:@"synonyms"];
			[m setValue:[n stringForXPath:@"series_image" ] forKey:@"image_url"];
			[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_status"] intValue]] forKey:@"my_status"];
			[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_score"] intValue]] forKey:@"score"];
			[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_id"] intValue]] forKey:@"my_id"];
			[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"series_type"] intValue]] forKey:@"type"];
			if([__type isEqual:@"anime"]){
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"series_episodes"] intValue]] forKey:@"episodes"];
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_watched_episodes"] intValue]] forKey:@"my_episodes"];
				[m setValue:[NSNumber numberWithBool:[[n stringForXPath:@"my_rewatching"] boolValue]] forKey:@"my_rewatching"];
				//[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_rewatching_ep"] intValue]] forKey:@"my_rewatching_ep"];
			} else { // manga
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"series_chapters"] intValue]] forKey:@"chapters"];
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_read_chapters"] intValue]] forKey:@"my_chapters"];
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"series_volumes"] intValue]] forKey:@"volumes"];
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_read_volumes"] intValue]] forKey:@"my_volumes"];
				// rereadingg is a typo by Xinil in the XML :|
				[m setValue:[NSNumber numberWithBool:[[n stringForXPath:@"my_rereadingg"] boolValue]] forKey:@"my_rereading"];
				[m setValue:[NSNumber numberWithInt:[[n stringForXPath:@"my_rereading_chap"] intValue]] forKey:@"my_rereading_chap"];
			}
		}
	}
	
	if([self.__type isEqual:@"anime"])
		[mal.queue addOperation:[[[IndexOperation alloc] initWithContext:self.__db update:self.__update callback:__done]autorelease]];
	else
		[__done perform];
	
}

@end
