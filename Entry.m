//
//  Entry.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "Entry.h"
#import "NSImage+NiceScaling.h"


@implementation Entry

- (NSImage *) scaledImage
{
	if(_img == nil){
		NSImage * _imgunscaled = [[NSImage alloc] initWithContentsOfFile: [self valueForKey:@"image_path"]];
		_img = [_imgunscaled scaledImageToCoverSize:NSMakeSize(63.0, 90.0)];
		[_imgunscaled release];
		[_img retain];
	}
	return _img;
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
