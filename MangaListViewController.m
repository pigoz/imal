//
//  MangaListViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "MangaListViewController.h"


@implementation MangaListViewController

@synthesize __db;

-(id)initWithContext:(NSManagedObjectContext *) db
{
	if(![super initWithNibName:@"MangaList" bundle:nil])
		return nil;
	self.__db = db;
	return self;
}

@end
