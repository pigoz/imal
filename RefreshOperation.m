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


@implementation RefreshOperation

@synthesize __type;
@synthesize __db;

-(RefreshOperation *) initWithType:(NSString *) type context:(NSManagedObjectContext *) db
{
	self = [super init];
	if (self != nil) {
		self.__type = type;
		self.__db = db;
	}
	return self;
}


-(void)main
{
	MALHandler * mal = [MALHandler sharedHandler];
	NSData * _result = [mal getList:self.__type];
	
	if(_result != nil){ // recived something
		NSError* error;
		NSXMLDocument * doc = [[NSXMLDocument alloc] initWithData:_result options:NSXMLDocumentTidyXML error:&error];
		NSArray * entryNodes = [doc nodesForXPath:[NSString stringWithFormat:@"myanimelist/%@",__type] error:&error];
		for(NSXMLNode * n in entryNodes){
			NSInteger __id = [[n stringForXPath:[NSString stringWithFormat:@"series_%@db_id", __type]] intValue];
			NSManagedObject * m = [__db fetchOrCreateForEntityName:__type withID:__id];
			[m setValue:[n stringForXPath:@"series_title"] forKey:@"title"];
			[m setValue:[n stringForXPath:@"series_image" ] forKey:@"image_url"];
		}
	}
	
}

@end
