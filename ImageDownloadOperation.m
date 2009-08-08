//
//  ImageDownloadOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "ImageDownloadOperation.h"
#import "PGZCallback.h"
#import "NSImage+NiceScaling.h"

@implementation ImageDownloadOperation

@synthesize __url;
@synthesize __type;
@synthesize __id;
@synthesize __callback;

-(ImageDownloadOperation *) initWithURL:(NSString *) url type:(NSString *) type entryid:(NSInteger) entryid callback:(PGZCallback *) callback
{
	self = [super init];
	if (self != nil) {
		self.__url = url;
		self.__type = type;
		self.__id = entryid;
		self.__callback = callback;
	}
	return self;
}

-(void)main
{
	NSData *fetchedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.__url]];
	NSString * filename = [NSString 
				stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/%@/%d.jpg",NSUserName(),self.__type,self.__id];
	NSImage * image = [[[NSImage alloc] initWithData:fetchedData] autorelease];
	
	image = [image scaledImageToCoverSize:NSMakeSize(225.0, 350.0)];
	
	NSData *imageData = [image  TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor];
	imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
	[imageData writeToFile:filename atomically:NO];
	
	[__callback performWithObject:image];
}

@end
