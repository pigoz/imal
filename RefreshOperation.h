//
//  RefreshOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PGZCallback;

@interface RefreshOperation : NSOperation {
	NSString * __type;
	NSManagedObjectContext * __db;
	PGZCallback * __start;
	PGZCallback * __done;
}

@property (retain) NSString * __type;
@property (retain) NSManagedObjectContext * __db;
@property (retain) PGZCallback * __start;
@property (retain) PGZCallback * __done;

-(RefreshOperation *) initWithType:(NSString *) type context:(NSManagedObjectContext *) db 
							 start:(PGZCallback *) start done:(PGZCallback *) done;

@end
