//
//  ListViewController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class InfoWindowController;

@interface ListViewController : NSViewController {
	NSManagedObjectContext * __db;
	NSString * __type;
	IBOutlet IKImageBrowserView * mImageBrowser;
	InfoWindowController * infoPanelController;
	
	BOOL watchingFlag;
	BOOL holdFlag;
	BOOL completedFlag;
	BOOL droppedFlag;
	BOOL planFlag;
	NSString * searchString;
	
	IBOutlet NSArrayController * __array_controller;
	NSArray * __sort;
	
	NSString * wrString; // watching/reading string
	NSString * planString; // plan to read/watch
}

@property (retain) NSManagedObjectContext * __db;
@property (retain) NSString * __type;
@property (assign) BOOL watchingFlag;
@property (assign) BOOL holdFlag;
@property (assign) BOOL completedFlag;
@property (assign) BOOL droppedFlag;
@property (assign) BOOL planFlag;
@property (retain) NSString * searchString;
@property (retain) NSArray * __sort;
@property (retain) NSString * wrString;
@property (retain) NSString * planString;

@property (retain) NSArrayController * __array_controller;

@property (retain) IKImageBrowserView * mImageBrowser;

-(IBAction)increaseEp:(id)sender;
-(IBAction)decreaseEp:(id)sender;
-(IBAction)showInfoPanel:(id)sender;
-(id)initWithType:(NSString*) type context:(NSManagedObjectContext *) db;
-(void)constructPredicate;

@end
