//
//  SearchController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchController : NSObject {
	NSMutableArray * __entries;
	IBOutlet NSTextField * searchField;
	IBOutlet NSTableView * tableView;
	IBOutlet NSPopUpButton * popupButton;
	IBOutlet NSWindow * searchWindow;
	IBOutlet NSView * infoView;
	IBOutlet NSScrollView * scrollView;
	IBOutlet NSProgressIndicator * spinner;
	IBOutlet NSArrayController * __entries_controller;
	
	BOOL showing_info;
}

@property (retain) NSMutableArray * __entries;

-(IBAction) search:(id)sender;
-(void) callback:(NSArray *) returnArray;

@end
