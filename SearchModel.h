//
//  SearchModel.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/3/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchModel : NSObject {
	NSString * __title;
	NSString * __synonyms;
	NSString * __type;
	NSString * __image_url;
	float __score;
	int __episodes;
	
	NSString * __status;
	NSString * __start_date;
	NSString * __end_date;
	
	NSString * __synopsis;
	
	NSImage * __scaled_image;
}

@property (retain) NSString * __title;
@property (retain) NSString * __synonyms;
@property (retain) NSString * __type;
@property (retain) NSString * __image_url;
@property (assign) float __score;
@property (assign) int __episodes;
@property (retain) NSString * __status;
@property (retain) NSString * __start_date;
@property (retain) NSString * __end_date;
@property (retain) NSString * __synopsis;

-(NSImage *)__image;

-(NSAttributedString *)__bold_title;
-(NSAttributedString *)__formatted_synopsis;

@end
