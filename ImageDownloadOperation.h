//
//  ImageDownloadOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PGZCallback;

@interface ImageDownloadOperation : NSOperation {
	NSString * __url;
	NSString * __type;
	NSInteger __id;
	PGZCallback * __callback;
	PGZCallback * __cancelled;
}

-(ImageDownloadOperation *) initWithURL:(NSString *) url type:(NSString *) type entryid:(NSInteger) entryid callback:(PGZCallback *) callback;

@property (retain) NSString * __url;
@property (retain) NSString *__type;
@property (assign) NSInteger __id;
@property (retain) PGZCallback * __callback;

@property (retain) PGZCallback * __cancelled;

@end
