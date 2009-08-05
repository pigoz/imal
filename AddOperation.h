//
//  AddOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/5/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SearchWindowController;

@interface AddOperation : NSOperation {
	int __id;
	NSMutableDictionary * __values;
	NSString * __type;
	SearchWindowController * __controller;
}

@property (assign) int __id;
@property (retain) NSMutableDictionary * __values;
@property (retain) NSString * __type;
@property (retain) SearchWindowController * __controller;

@end
