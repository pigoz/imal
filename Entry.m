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

@implementation Entry

- (NSImage *) scaledImage
{
	if(_img == nil){
		NSString * image_path = [NSString 
								 stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/%@/%@.jpg",NSUserName(),
								 [[self entity] name],[self valueForKey:@"id"]];
		NSImage * _imgunscaled = [[NSImage alloc] initWithContentsOfFile: image_path];
		if(_imgunscaled){
			_img = [_imgunscaled scaledImageToCoverSize:NSMakeSize(63.0, 90.0)];
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
		_img = [downloadedImage scaledImageToCoverSize:NSMakeSize(63.0, 90.0)];
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
