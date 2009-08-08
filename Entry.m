//
//  Entry.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "Entry.h"
#import "NSImage+NiceScaling.h"

#import "MALHandler.h"
#import "PGZCallback.h"
#import "ImageDownloadOperation.h"

#import <Quartz/Quartz.h>

@implementation Entry

- (id) init
{
	self = [super init];
	if (self != nil) {
		startedOpearion = NO;
	}
	return self;
}

- (NSString *)imageTitle
{
	NSString * _result = [(NSString* )[self valueForKey:@"title"] stringByMatching:@"&apos;" replace: 5 withReferenceString:@"'"];
	_result = [_result stringByMatching:@"&amp;" replace:5 withReferenceString:@"&"];
	return _result;
}

- (NSString *)imageSubtitle
{
	if([[self valueForKey:@"my_status"] intValue] == 1)
		return [NSString stringWithFormat:@"Watching: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
	if([[self valueForKey:@"my_status"] intValue] == 2)
		return @"Completed";
	if([[self valueForKey:@"my_status"] intValue] == 3)
		return [NSString stringWithFormat:@"On hold: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
	if([[self valueForKey:@"my_status"] intValue] == 4)
		return [NSString stringWithFormat:@"Dropped: %@/%@ episodes", [self valueForKey:@"my_episodes"],[self valueForKey:@"episodes"]];
	if([[self valueForKey:@"my_status"] intValue] == 6)
		return @"Plan to Watch";
	return nil;
}

- (NSString *)imageUID {
    return (NSString* )[self valueForKey:@"image_url"];
}

- (NSString *) imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (id) imageRepresentation
{
	if(_img == nil && !startedOpearion){
		NSString * image_path = [NSString 
								 stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/%@/%@.jpg",NSUserName(),
								 [[self entity] name],[self valueForKey:@"id"]];
		NSImage * _imgunscaled = [[NSImage alloc] initWithContentsOfFile: image_path];
		if(_imgunscaled){
			_img = [_imgunscaled scaledImageToCoverSize:NSMakeSize(225.0, 350.0)];
			[_imgunscaled release];
			[_img retain];
		} else {
			MALHandler *mal = [MALHandler sharedHandler];
			NSString * url = (NSString*) [self valueForKey:@"image_url"];
			PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(scaledImageCallback:)];
			[mal.queue addOperation:[[ImageDownloadOperation alloc] initWithURL:url type:[[self entity] name] 
																		entryid:[[self valueForKey:@"id"] intValue] 
																	   callback:callback]];
			_img = nil;
		}
	}
	return _img;
}


- (NSImage *) scaledImage
{
	startedOpearion = NO;
	if(_img == nil){
		NSString * image_path = [NSString 
								 stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/%@/%@.jpg",NSUserName(),
								 [[self entity] name],[self valueForKey:@"id"]];
		NSImage * _imgunscaled = [[NSImage alloc] initWithContentsOfFile: image_path];
		if(_imgunscaled){
			_img = [_imgunscaled scaledImageToCoverSize:NSMakeSize(225.0, 350.0)];
			[_imgunscaled release];
			[_img retain];
		} else {
			MALHandler *mal = [MALHandler sharedHandler];
			NSString * url = (NSString*) [self valueForKey:@"image_url"];
			PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(scaledImageCallback:)];
			[mal.queue addOperation:[[ImageDownloadOperation alloc] initWithURL:url type:[[self entity] name] 
																		entryid:[[self valueForKey:@"id"] intValue] 
																	   callback:callback]];
			return nil;
		}
	}
	return _img;
}

- (void) scaledImageCallback:(NSImage *) downloadedImage
{
	[self willChangeValueForKey:@"scaledImage"];
		_img = [downloadedImage scaledImageToCoverSize:NSMakeSize(100.0, 155.0)];
		[_img retain];
	[self didChangeValueForKey:@"scaledImage"];
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
