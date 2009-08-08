//
//  AnimeListViewController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AnimeListViewController : NSViewController {
	NSManagedObjectContext * __db;
	IBOutlet IKImageBrowserView * mImageBrowser;
	
	BOOL watchingFlag;
	BOOL holdFlag;
	BOOL completedFlag;
	BOOL droppedFlag;
	BOOL planFlag;
	NSString * searchString;
	
	IBOutlet NSArrayController * __array_controller;
	NSArray * __sort;
}

@property (retain) NSManagedObjectContext * __db;
@property (assign) BOOL watchingFlag;
@property (assign) BOOL holdFlag;
@property (assign) BOOL completedFlag;
@property (assign) BOOL droppedFlag;
@property (assign) BOOL planFlag;
@property (retain) NSString * searchString;
@property (retain) NSArray * __sort;


-(id)initWithContext:(NSManagedObjectContext *) db;
-(void)constructPredicate;

@end
