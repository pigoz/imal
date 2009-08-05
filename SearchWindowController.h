//
//  SearchController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchWindowController : NSWindowController {
	IBOutlet NSTextField * animeSearchField;
	IBOutlet NSTableView * animeTableView;
	IBOutlet NSProgressIndicator * animeSpinner;
	IBOutlet NSScrollView * animeScrollView;
	IBOutlet NSView * animeInfoView;
	IBOutlet NSView * animeTab;
	
	IBOutlet NSView * addAnime;
	IBOutlet NSView * episodesField;
	IBOutlet NSProgressIndicator * addAnimeSpinner;
	
	IBOutlet NSArrayController * __entries_controller;
	NSMutableArray * __entries;

	BOOL showing_info;
}

@property (retain) NSMutableArray * __entries;

-(IBAction) searchAnime:(id)sender;
-(IBAction) addAnime:(id)sender;

-(void) callback:(NSArray *) returnArray;

-(id)init;
-(void)windowDidLoad;

@end
