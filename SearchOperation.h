//
//  SearchOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchOperation : NSOperation {

	NSString * __query;
	NSString * __type;
	SEL __callback;
	
}

-(SearchOperation *) initWithQuery:(NSString *) query withType:(NSString *) type callback:(SEL)callback;

@end
