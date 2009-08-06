//
//  RefreshOperation.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RefreshOperation : NSOperation {
	NSString * __type;
	NSManagedObjectContext * __db;
}

@property (retain) NSString * __type;
@property (retain) NSManagedObjectContext * __db;

-(RefreshOperation *) initWithType:(NSString *) type context:(NSManagedObjectContext *) db;

@end
