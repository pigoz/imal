//
//  AddOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/5/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AddOperation.h"
#import "SearchWindowController.h"

@implementation AddOperation

@synthesize __id;
@synthesize __type;
@synthesize __values;
@synthesize __controller;

-(AddOperation *) initWithID:(int) entryID withType:(NSString *) type values:(NSMutableDictionary*) values controller:(SearchWindowController *) controller
{
	self = [super init];
	if (self != nil) {
		self.__id = entryID;
		self.__type = type;
		self.__values = values;
		self.__controller = controller;
	}
	return self;
}

@end
