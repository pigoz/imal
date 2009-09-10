//
//  Trigram.h
//  iMAL
//
//  Created by Stefano Pigozzi on 9/10/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQLitePersistentObject.h"

@interface Trigram : SQLitePersistentObject {
	NSString * trigram;
	int score;
	int anime_id;
}

@property (nonatomic, retain) NSString * trigram;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int anime_id;

@end
