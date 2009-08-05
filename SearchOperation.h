//
//  SearchOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PGZCallback;

@interface SearchOperation : NSOperation {

	NSString * __query;
	NSString * __type;
	PGZCallback * __callback;
	
}

@property (retain) NSString * __query;
@property (retain) NSString * __type;
@property (retain) PGZCallback * __callback;

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type callback:(PGZCallback *) callback;

@end
