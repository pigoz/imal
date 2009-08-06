//
//  SearchModel.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/3/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchModel.h"
#import "NSImage+NiceScaling.h"
#import "NSXMLNode+stringForXPath.h"

#import "MALHandler.h"
#import "PGZCallback.h"
#import "ImageDownloadOperation.h"

@implementation SearchModel

@synthesize __id;
@synthesize __title;
@synthesize __synonyms;
@synthesize __type;
@synthesize __episodes;
@synthesize __chapters;
@synthesize __volumes;
@synthesize __score;
@synthesize __image_url;
@synthesize __status;
@synthesize __start_date;
@synthesize __end_date;
@synthesize __synopsis;

-(SearchModel *) initAnimeFromXMLNode:(NSXMLNode *)n
{
	self = [super init];
	if (self != nil) {
		self.__id = [[n stringForXPath:@"id"] intValue];
		self.__title = [n stringForXPath:@"title"];
		self.__type = [n stringForXPath:@"type"];
		self.__score = [[n stringForXPath:@"score"] floatValue];
		self.__episodes = [[n stringForXPath:@"episodes"] intValue];
		self.__image_url = [n stringForXPath:@"image"];
		self.__synonyms = [n stringForXPath:@"synonyms"];
		self.__status = [n stringForXPath:@"status"];
		self.__start_date = [n stringForXPath:@"start_date"];
		self.__end_date = [n stringForXPath:@"end_date"];
		self.__synopsis = [n stringForXPath:@"synopsis"];
	}
	return self;
}

-(SearchModel *) initMangaFromXMLNode:(NSXMLNode *)n
{
	self = [super init];
	if (self != nil) {
		self.__id = [[n stringForXPath:@"id"] intValue];
		self.__title = [n stringForXPath:@"title"];
		self.__type = [n stringForXPath:@"type"];
		self.__score = [[n stringForXPath:@"score"] floatValue];
		self.__chapters = [[n stringForXPath:@"chapters"] intValue];
		self.__volumes = [[n stringForXPath:@"volumes"] intValue];
		self.__image_url = [n stringForXPath:@"image"];
		self.__synonyms = [n stringForXPath:@"synonyms"];
		self.__status = [n stringForXPath:@"status"];
		self.__start_date = [n stringForXPath:@"start_date"];
		self.__end_date = [n stringForXPath:@"end_date"];
		self.__synopsis = [n stringForXPath:@"synopsis"];
	}
	return self;
}

-(NSAttributedString *)__bold_title
{
	NSData * s = [[NSString stringWithFormat:@"<font face=\"Lucida Grande\" size =\"4\"><b>%@</b></font>",self.__title] 
				  dataUsingEncoding:NSUTF8StringEncoding];
	return [[NSAttributedString alloc] initWithHTML: s documentAttributes:NULL];
}

-(NSString *)__date_status
{
	return [NSString stringWithFormat:@"Status: %@, Start date: %@, End date: %@", self.__status, self.__start_date, self.__end_date];
}

-(NSAttributedString *)__formatted_synopsis
{
	NSData * s = [[NSString stringWithFormat:@"<font face=\"Lucida Grande\" size =\"1\">%@</font>",self.__synopsis]  
				  dataUsingEncoding:NSUTF8StringEncoding];
	return [[NSAttributedString alloc] initWithHTML: s documentAttributes:NULL];
}

-(NSImage *)__image
{
	if(!__scaled_image){
		MALHandler *mal = [MALHandler sharedHandler];
		PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(scaledImageCallback:)];
		[mal.queue addOperation:[[ImageDownloadOperation alloc] initWithURL:self.__image_url type:self.__type 
																	entryid:self.__id 
																   callback:callback]];
		return nil;
	}
	return __scaled_image;
}

- (void) scaledImageCallback:(NSImage *) downloadedImage
{
	[self willChangeValueForKey:@"__image"];
	__scaled_image = [downloadedImage scaledImageToCoverSize:NSMakeSize(100.0, 155.0)];
	[__scaled_image retain];
	[self didChangeValueForKey:@"__image"];
}

@end
