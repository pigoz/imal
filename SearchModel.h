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
	NSString * __type;
	int __score;
	int __episodes;
}

@property (retain) NSString * __title;
@property (retain) NSString * __type;
@property (assign) int __score;
@property (assign) int __episodes;

@end
