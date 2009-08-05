//
//  PGZCallback.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/5/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PGZCallback : NSObject {
	id __instance;
	SEL __selector;
	id __object;
}

@property (retain) id __instance;
@property (assign) SEL __selector;
@property (retain) id __object;

-(PGZCallback *) initWithInstance:(id)instance selector:(SEL) selector argumentObject:(id)object;
-(PGZCallback *) initWithInstance:(id)instance selector:(SEL) selector;

-(void) performWithObject:(id)object;
-(void) perform;

@end
