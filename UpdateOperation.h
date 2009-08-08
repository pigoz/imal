//
//  UpdateOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PGZCallback;

@interface UpdateOperation : NSOperation {
	int __id;
	NSMutableDictionary * __values;
	NSString * __type;
	PGZCallback * __callback;
}

@property (assign) int __id;
@property (retain) NSMutableDictionary * __values;
@property (retain) NSString * __type;
@property (retain) PGZCallback * __callback;

-(UpdateOperation *) initWithID:(int) entryID withType:(NSString *) type values:(NSMutableDictionary*) values callback:(PGZCallback *) callback;

@end
