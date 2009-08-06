//
//  Entry.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Entry : NSManagedObject {

	NSImage * _img; // scaled image
	
}

-(NSImage *) scaledImage;
-(NSAttributedString *)__bold_title;

@end
