//
//  AnimeListViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AnimeListViewController.h"


@implementation AnimeListViewController

@synthesize __db;

-(id)initWithContext:(NSManagedObjectContext *) db
{
	if(![super initWithNibName:@"AnimeList" bundle:nil])
		return nil;
	self.__db = db;
	return self;
}

-(IBAction)asd
{
	NSLog(@"%@", self.__db);
}

@end
