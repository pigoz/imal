//
//  MALHandler.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MALHandler : NSObject {
	NSOperationQueue * queue;
}

+ (MALHandler *)sharedHandler;
- (NSData *) get:(NSString *) resource;
- (NSData *) post:(NSString *) resource data:(NSString *) data;
- (NSData *) search:(NSString *) query type:(NSString *) type;

@property (retain, readonly) NSOperationQueue *queue;

@end
