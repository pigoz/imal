//
//  MALHandler.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// STATUS CONSTANTS
typedef enum statusValues {
	MALWatching = 1,
	MALCompleted = 2,
	MALOnHold = 3,
	MALDropped = 4,
	MALPlantoWatch = 6,
} statusValues;

static const int MALReading = MALWatching;
static const int MALPlantoRead = MALPlantoWatch;

@interface MALHandler : NSObject {
	NSOperationQueue * queue; // queue to be used for small operations
	NSOperationQueue * dl_queue; // que to be used for batched of operations, i.e.: ImageDownloadOperations
}

+ (MALHandler *)sharedHandler;
- (NSData *) get:(NSString *) resource;
- (NSData *) post:(NSString *) resource data:(NSData *) data;
- (NSData *) search:(NSString *) query type:(NSString *) type;
- (NSData *) getList:(NSString *)type;

@property (retain, readonly) NSOperationQueue *queue;
@property (retain, readonly) NSOperationQueue *dl_queue;

@end
