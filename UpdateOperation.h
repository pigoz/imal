//
//  UpdateOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Entry;

@class PGZCallback;

@interface UpdateOperation : NSOperation {
	Entry * __entry;
	NSMutableDictionary * __values;
	PGZCallback * __callback;
}

@property (retain) Entry * __entry;
@property (retain) NSMutableDictionary * __values;
@property (retain) PGZCallback * __callback;

-(UpdateOperation *) initWithEntry:(Entry *) entry values:(NSMutableDictionary*) values callback:(PGZCallback *) callback;

@end
