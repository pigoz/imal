//
//  MALHandler.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MALHandler : NSObject {
}

- (NSData *) get:(NSString *) resource;
- (NSData *) post:(NSString *) resource data:(NSString *) data;

@end
