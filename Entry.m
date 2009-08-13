//
//  Entry.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "Entry.h"
#import "NSImage+NiceScaling.h"
#import "NSXMLNode+stringForXPath.h"

#import "MALHandler.h"
#import "PGZCallback.h"
#import "ImageDownloadOperation.h"

#import <Quartz/Quartz.h>

@implementation Entry

@synthesize __title;

- (id) init
{
	self = [super init];
	if (self != nil) {
		__img = nil;
		__downloadOperation = nil;
	}
	return self;
}

- (NSString *)imageTitle
{
	if(!__title){
		NSString * _result = [(NSString* )[self valueForKey:@"title"] stringByMatching:@"&apos;" replace: 5 withReferenceString:@"'"];
		self.__title = [_result stringByMatching:@"&amp;" replace:5 withReferenceString:@"&"];
	}
	return __title;
}

- (NSString *)imageSubtitle
{
	if([[[self entity] name] isEqual:@"anime"]){
		if([[self valueForKey:@"my_status"] intValue] == 1)
			if([[self valueForKey:@"my_rewatching"] boolValue])
				return [NSString stringWithFormat:@"Re-Watching: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
			else
				return [NSString stringWithFormat:@"Watching: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
		if([[self valueForKey:@"my_status"] intValue] == 2)
			return @"Completed";
		if([[self valueForKey:@"my_status"] intValue] == 3)
			return [NSString stringWithFormat:@"On hold: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
		if([[self valueForKey:@"my_status"] intValue] == 4)
			return [NSString stringWithFormat:@"Dropped: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
		if([[self valueForKey:@"my_status"] intValue] == 6)
			return @"Plan to Watch";
	}
	if([[[self entity] name] isEqual:@"manga"]){
		if([[self valueForKey:@"my_status"] intValue] == 1)
			return [NSString stringWithFormat:@"Reading: %@/%@ chapters", [self valueForKey:@"my_chapters"],[self valueForKey:@"chapters"]];
		if([[self valueForKey:@"my_status"] intValue] == 2)
			return @"Completed";
		if([[self valueForKey:@"my_status"] intValue] == 3)
			return [NSString stringWithFormat:@"On hold: %@/%@ chapters", [self valueForKey:@"my_chapters"],[self valueForKey:@"chapters"]];
		if([[self valueForKey:@"my_status"] intValue] == 4)
			return [NSString stringWithFormat:@"Dropped: %@/%@ episodes", [self valueForKey:@"my_chapters"],[self valueForKey:@"chapters"]];
		if([[self valueForKey:@"my_status"] intValue] == 6)
			return @"Plan to Read";
	}
	return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	// notifies observers of the imageSubtitle property when an update is done :)
	if([key isEqual:@"my_status"] || [key isEqual:@"my_episodes"] || [key isEqual:@"my_chapters"] || [key isEqual:@"my_rewatching"]){
		[self willChangeValueForKey:@"imageSubtitle"];
		[super setValue:value forKey:key];
		[self didChangeValueForKey:@"imageSubtitle"];
	} else {
		[super setValue:value forKey:key];
	}
}

- (NSString *)imageUID {
    return (NSString* )[self valueForKey:@"image_url"];
}

- (NSString *) imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

-(void)imageDownloadCancel
{
	__downloadOperation = nil;
}

- (id) imageRepresentation
{
	if(!__img){ //image not cached in memory
		NSString * image_path = [NSString
					stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/%@/%@.jpg",NSUserName(),
										[[self entity] name],[self valueForKey:@"id"]];
		__img = [[NSImage alloc] initWithContentsOfFile: image_path];
		return __img;
	}
	if(!__img && !__downloadOperation){
		MALHandler *mal = [MALHandler sharedHandler];
		NSString * url = (NSString*) [self valueForKey:@"image_url"];
		PGZCallback * callback = [[[PGZCallback alloc] initWithInstance:self selector:@selector(scaledImageCallback:)] autorelease];
		__downloadOperation = [[[ImageDownloadOperation alloc] initWithURL:url type:[[self entity] name] 
																  entryid:[[self valueForKey:@"id"] intValue] 
																 callback:callback] autorelease];
		__downloadOperation.__cancelled = [[[PGZCallback alloc] initWithInstance:self selector:@selector(imageDownloadCancel)] autorelease];
		[mal.dl_queue addOperation:__downloadOperation];
	}
	return __img;
}

- (void) scaledImageCallback:(NSImage *) downloadedImage
{
	[self willChangeValueForKey:@"imageRepresentation"];
	__img = [downloadedImage retain];
	[self didChangeValueForKey:@"imageRepresentation"];
}

- (NSString *) niceAnimeID
{
	return [NSString stringWithFormat:@"#%@", [self valueForKey:@"id"]];
}

-(NSAttributedString *)__bold_title
{
	NSData * s = [[NSString stringWithFormat:@"<font face=\"Lucida Grande\" size =\"3\"><b>%@</b></font>",(NSString*)[self valueForKey:@"title"]] 
				  dataUsingEncoding:NSUTF8StringEncoding];
	return [[NSAttributedString alloc] initWithHTML: s documentAttributes:NULL];
}

@end
