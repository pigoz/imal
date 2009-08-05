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
	NSOperationQueue * queue;
}

+ (MALHandler *)sharedHandler;
- (NSData *) get:(NSString *) resource;
- (NSData *) post:(NSString *) resource data:(NSData *) data;
- (NSData *) search:(NSString *) query type:(NSString *) type;

@property (retain, readonly) NSOperationQueue *queue;

@end
