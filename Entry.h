//
//  Entry.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ImageDownloadOperation;

@interface Entry : NSManagedObject {

	NSImage * __img; // scaled image
	NSString * __title;
	
	ImageDownloadOperation * __downloadOperation;
}

@property (retain) NSString * __title;
-(NSAttributedString *)__bold_title;
-(NSString *)imageTitle;
-(NSString *)imageSubtitle;
-(id)imageRepresentation;

@end
