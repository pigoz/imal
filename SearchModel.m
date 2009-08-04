//
//  SearchModel.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/3/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchModel.h"
#import "NSImage+NiceScaling.h"

@implementation SearchModel

@synthesize __title;
@synthesize __synonyms;
@synthesize __type;
@synthesize __episodes;
@synthesize __score;
@synthesize __image_url;
@synthesize __status;
@synthesize __start_date;
@synthesize __end_date;
@synthesize __synopsis;

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
	NSImage * unscaledImage =  [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:__image_url]];
	__scaled_image = [unscaledImage scaledImageToCoverSize:NSMakeSize(100.0, 155.0)];
	[unscaledImage release];
	return __scaled_image;
}

@end
