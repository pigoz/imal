//
//  SearchController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchWindowController : NSWindowController {
	
	NSManagedObjectContext * __db;
	
	// TABS
	IBOutlet NSTabView * tabView;
	IBOutlet NSView * animeTab;
	IBOutlet NSView * mangaTab;
	
	// Anime views always visible
	IBOutlet NSTextField * animeSearchField;
	IBOutlet NSTableView * animeTableView;
	IBOutlet NSProgressIndicator * animeSpinner;
	IBOutlet NSScrollView * animeScrollView;
	
	// Manga views always visible
	IBOutlet NSTextField * mangaSearchField;
	IBOutlet NSTableView * mangaTableView;
	IBOutlet NSProgressIndicator * mangaSpinner;
	IBOutlet NSScrollView * mangaScrollView;

	// Anime Add Controls
	IBOutlet NSView * addAnime;
	IBOutlet NSTextField * episodesField;
	IBOutlet NSProgressIndicator * addAnimeSpinner;
	IBOutlet NSPopUpButton * animeStatus;	

	// Manga Add Controls
	IBOutlet NSView * addManga;
	IBOutlet NSTextField * chaptersField;
	IBOutlet NSTextField * volumesField;
	IBOutlet NSProgressIndicator * addMangaSpinner;
	IBOutlet NSPopUpButton * mangaStatus;
	
	// Info Views (bound to the NSArrayControllers)
	IBOutlet NSView * animeInfoView;
	IBOutlet NSView * mangaInfoView;
	
	IBOutlet NSView * animeAlredyInYourList;
	IBOutlet NSView * mangaAlredyInYourList;
	
	// Managed Models
	IBOutlet NSArrayController * __anime_entries_controller;
	NSMutableArray * __anime_entries;
	IBOutlet NSArrayController * __manga_entries_controller;
	NSMutableArray * __manga_entries;

	// Showing info states
	BOOL __showing_anime_info;
	BOOL __showing_manga_info;
	
	NSRect __anime_frame;
	NSRect __manga_frame;
	
	BOOL __was_showing_anime_info;
	BOOL __was_showing_manga_info;
	
}

@property (retain) NSManagedObjectContext * __db;

@property (retain) NSMutableArray * __anime_entries;
@property (retain) NSMutableArray * __manga_entries;

-(IBAction) searchAnime:(id)sender;
-(IBAction) addAnime:(id)sender;
-(IBAction) searchManga:(id)sender;
-(IBAction) addManga:(id)sender;

-(void)windowDidLoad;

@end
