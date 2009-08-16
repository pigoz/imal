//
//  IndexOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/16/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PGZCallback;

@interface IndexOperation : NSOperation {
	NSManagedObjectContext * __db;
	PGZCallback * __done;
}

@property (retain) NSManagedObjectContext * __db;
@property (retain) PGZCallback * __done;

-(IndexOperation *)initWithContext:(NSManagedObjectContext *)ctx callback:(PGZCallback *) cb;

@end
