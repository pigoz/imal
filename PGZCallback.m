//
//  PGZCallback.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/5/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "PGZCallback.h"


@implementation PGZCallback

@synthesize __instance;
@synthesize __selector;
@synthesize __object;

-(PGZCallback *) initWithInstance:(id)instance selector:(SEL) selector argumentObject:(id)object
{
	self = [super init];
	if (self != nil) {
		self.__instance = instance;
		self.__selector = selector;
		self.__object = object;
	}
	return self;
}
-(PGZCallback *) initWithInstance:(id)instance selector:(SEL) selector
{
	return [self initWithInstance:instance selector:selector argumentObject:nil];
}

-(void) perform
{
	if([__instance respondsToSelector:__selector]){
		if(!self.__object){
			[__instance performSelector:__selector];
		} else {
			[__instance performSelector:__selector withObject:__object];
		}
		
	}
}

-(void) performWithObject:(id)object
{
	self.__object = object;
	[self perform];
}

@end
