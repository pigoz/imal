//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchWindowController.h"
#import "MALHandler.h"
#import "AddOperation.h"
#import "SearchOperation.h"
#import "SearchModel.h"
#import "PGZCallback.h"


@implementation SearchWindowController

@synthesize __anime_entries;
@synthesize __manga_entries;


-(id)init
{
	if(![super initWithWindowNibName:@"SearchPanel"])
		return nil;
	return self;
}
-(void)windowDidLoad
{
	NSLog(@"Loaded search window");
}

-(void)awakeFromNib
{	
	// observe the selection
	[__anime_entries_controller addObserver:self forKeyPath:@"selectedObjects" 
									options:(NSKeyValueObservingOptionNew) 
									context:NULL];
	[__manga_entries_controller addObserver:self forKeyPath:@"selectedObjects" 
									options:(NSKeyValueObservingOptionNew) 
									context:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willTerminate:)
												 name:NSApplicationWillTerminateNotification 
											   object:nil];
	
	__showing_anime_info = NO;
	__showing_manga_info = NO;
	__was_showing_anime_info = NO;
	__was_showing_manga_info = NO;
	__anime_frame = [self.window frame];
	__manga_frame = [self.window frame];
}

/// Helper Method: converts popup tag [0,5] to MAL status [1,4]U[6]
-(int) PopUpToMALStatus:(int)status
{
	switch (status)
	{
		case 4:	return MALPlantoWatch;
		default: return status-1;
	}
}


-(IBAction) searchAnime:(id) sender
{
	[animeSpinner startAnimation:nil];
	[animeSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * type = @"anime";
	PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(searchAnimeCallback:)];
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:[animeSearchField stringValue] withType:type callback: [callback autorelease]]];
}

-(void) searchAnimeCallback:(NSArray *) entries
{
	@synchronized(self){
		[self willChangeValueForKey:@"__anime_entries"];
		[__anime_entries release];
		__anime_entries = [entries retain];
		[self didChangeValueForKey:@"__anime_entries"];
		[animeSpinner stopAnimation:nil];
		[animeSpinner setHidden:YES];
	}
	
}

-(IBAction) searchManga:(id) sender
{
	[mangaSpinner startAnimation:nil];
	[mangaSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * type = @"manga";
	PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(searchMangaCallback:)];
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:[mangaSearchField stringValue] withType:type callback: [callback autorelease]]];
}

-(void) searchMangaCallback:(NSArray *) entries
{
	@synchronized(self){
		[self willChangeValueForKey:@"__manga_entries"];
		[__manga_entries release];
		__manga_entries = [entries retain];
		[self didChangeValueForKey:@"__manga_entries"];
		[mangaSpinner stopAnimation:nil];
		[mangaSpinner setHidden:YES];
	}
	
}

-(IBAction) addAnime:(id) sender
{
	[addAnimeSpinner startAnimation:nil];
	[addAnimeSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];

	SearchModel * sm = (SearchModel *)[[__anime_entries_controller selectedObjects] objectAtIndex:0];
	NSMutableDictionary * values = [[NSMutableDictionary alloc] init];
	[values setObject:[NSString stringWithFormat:@"%@", [episodesField stringValue]] forKey:@"episode"];
	[values setObject:[NSString stringWithFormat:@"%d", [self PopUpToMALStatus:[[animeStatus selectedCell] tag]]] forKey:@"status"];
	
	PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(addAnimeCallback:)];
	[mal.queue addOperation:[[AddOperation alloc] initWithID:sm.__id withType:@"anime" values:values callback:callback]];
}

-(void) addAnimeCallback:(NSArray *) entries
{
	@synchronized(self){
		[addAnimeSpinner stopAnimation:nil];
		[addAnimeSpinner setHidden:YES];
	}
	
}

-(IBAction) addManga:(id) sender
{
	[addMangaSpinner startAnimation:nil];
	[addMangaSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	
	SearchModel * sm = (SearchModel *)[[__manga_entries_controller selectedObjects] objectAtIndex:0];
	NSMutableDictionary * values = [[NSMutableDictionary alloc] init];
	[values setObject:[NSString stringWithFormat:@"%@", [chaptersField stringValue]] forKey:@"chapter"];
	[values setObject:[NSString stringWithFormat:@"%@", [volumesField stringValue]] forKey:@"volume"];
	[values setObject:[NSString stringWithFormat:@"%d", [[mangaStatus selectedCell] tag]] forKey:@"status"];
	
	PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(addMangaCallback:)];
	[mal.queue addOperation:[[AddOperation alloc] initWithID:sm.__id withType:@"manga" values:values callback:callback]];
}

-(void) addMangaCallback:(NSArray *) entries
{
	@synchronized(self){
		[addMangaSpinner stopAnimation:nil];
		[addMangaSpinner setHidden:YES];
	}
	
}

-(void)showAnimeInfo
{
	NSRect bounds = [animeInfoView bounds];
	NSRect i_bounds = [addAnime bounds];
	NSRect t_bounds = [animeTab bounds];
	NSRect w_frame = [self.window frame];
	
	w_frame.size.height += bounds.size.height + i_bounds.size.height;
	w_frame.origin.y -= bounds.size.height + i_bounds.size.height;
	
	// Locking the scrollview to the top 
	NSUInteger mask = [animeScrollView autoresizingMask]; // this was set in IB
	[animeScrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	[self.window setFrame:w_frame display:YES animate:YES];
	[animeInfoView setFrame:NSMakeRect(0.0, i_bounds.size.height, t_bounds.size.width, bounds.size.height)];
	[addAnime setFrame:NSMakeRect(0.0, 0.0, t_bounds.size.width, i_bounds.size.height)];
	
	//[[self.window contentView] addSubview:animeInfoView];
	[animeTab addSubview:animeInfoView];
	[animeTab addSubview:addAnime];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[animeScrollView setAutoresizingMask:mask];
	[animeScrollView setNextKeyView:episodesField];
	[episodesField setNextKeyView:animeSearchField];
	
	__showing_anime_info = YES;
}

-(void)showMangaInfo
{
	NSRect bounds = [mangaInfoView bounds];
	NSRect i_bounds = [addManga bounds];
	NSRect t_bounds = [mangaTab bounds];
	NSRect w_frame = [self.window frame];
	
	w_frame.size.height += bounds.size.height + i_bounds.size.height;
	w_frame.origin.y -= bounds.size.height + i_bounds.size.height;
	
	// Locking the scrollview to the top 
	NSUInteger mask = [mangaScrollView autoresizingMask]; // this was set in IB
	[mangaScrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	[self.window setFrame:w_frame display:YES animate:YES];
	[mangaInfoView setFrame:NSMakeRect(0.0, i_bounds.size.height, t_bounds.size.width, bounds.size.height)];
	[addManga setFrame:NSMakeRect(0.0, 0.0, t_bounds.size.width, i_bounds.size.height)];
	
	//[[self.window contentView] addSubview:animeInfoView];
	[mangaTab addSubview:mangaInfoView];
	[mangaTab addSubview:addManga];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[mangaScrollView setAutoresizingMask:mask];
	[mangaScrollView setNextKeyView:chaptersField];
	[chaptersField setNextKeyView:volumesField];
	[volumesField setNextKeyView:mangaSearchField];
	
	__showing_manga_info = YES;
}

-(void)hideAnimeInfo
{
	NSRect bounds = [animeInfoView bounds];
	NSRect i_bounds = [addAnime bounds];
	NSRect w_frame = [self.window frame];
	
	w_frame.size.height -= bounds.size.height + i_bounds.size.height;
	w_frame.origin.y += bounds.size.height + i_bounds.size.height;

	
	// Locking the scrollview to the top 
	NSUInteger mask = [animeScrollView autoresizingMask]; // this was set in IB
	[animeScrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	
	[addAnime removeFromSuperview];
	[animeInfoView removeFromSuperview];
	[self.window setFrame:w_frame display:YES animate:YES];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[animeScrollView setAutoresizingMask:mask];
	[animeScrollView setNextKeyView:nil];
	
	__showing_anime_info = NO;
}

-(void)hideMangaInfo
{
	NSRect bounds = [mangaInfoView bounds];
	NSRect i_bounds = [addManga bounds];
	NSRect w_frame = [self.window frame];
	
	w_frame.size.height -= bounds.size.height + i_bounds.size.height;
	w_frame.origin.y += bounds.size.height + i_bounds.size.height;
	
	
	// Locking the scrollview to the top 
	NSUInteger mask = [mangaScrollView autoresizingMask]; // this was set in IB
	[mangaScrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	
	[addManga removeFromSuperview];
	[mangaInfoView removeFromSuperview];
	[self.window setFrame:w_frame display:YES animate:YES];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[mangaScrollView setAutoresizingMask:mask];
	[mangaScrollView setNextKeyView:nil];
	
	__showing_manga_info = NO;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([object isEqual:__anime_entries_controller]){
		if([keyPath isEqual:@"selectedObjects"]){
			SearchModel * sm = nil;
			if([[__anime_entries_controller selectedObjects] count] > 0){
				sm = (SearchModel *)[[__anime_entries_controller selectedObjects] objectAtIndex:0];
			}
			if(sm!=nil && __showing_anime_info == NO){
				[self showAnimeInfo];
			}
			if(sm==nil && __showing_anime_info == YES){
				[self hideAnimeInfo];
			}	
			return;
		}
	}
	
	if([object isEqual:__manga_entries_controller]){
		if([keyPath isEqual:@"selectedObjects"]){
			SearchModel * sm = nil;
			if([[__manga_entries_controller selectedObjects] count] > 0){
				sm = (SearchModel *)[[__manga_entries_controller selectedObjects] objectAtIndex:0];
			}
			if(sm!=nil && __showing_manga_info == NO){
				[self showMangaInfo];
			}
			if(sm==nil && __showing_manga_info == YES){
				[self hideMangaInfo];
			}	
			return;
		}
	}
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if([[tabViewItem view]isEqual:animeTab]){
		__manga_frame = [self.window frame]; //I'm still on manga tab
	}
	if([[tabViewItem view]isEqual:mangaTab]){
		__anime_frame = [self.window frame]; //I'm still on anime tab
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if([[tabViewItem view]isEqual:animeTab]){
		NSRect new = [self.window frame];
		NSRect old = __anime_frame;
		NSRect frame = __anime_frame;
		frame.origin.y = new.origin.y - (old.size.height - new.size.height);
		frame.origin.x = new.origin.x - (old.size.width - new.size.width)/2;
		[self.window setFrame:frame display:YES animate:YES];
	}
	if([[tabViewItem view]isEqual:mangaTab]){
		NSRect new = [self.window frame];
		NSRect old = __manga_frame;
		NSRect frame = __manga_frame;
		frame.origin.y = new.origin.y - (old.size.height - new.size.height);
		frame.origin.x = new.origin.x - (old.size.width - new.size.width)/2;
		[self.window setFrame:frame display:YES animate:YES];
	}
}

- (void)willTerminate:(NSNotification *)notification
{
	if(__showing_anime_info && [[[tabView selectedTabViewItem] view]isEqual:animeTab])
		[self hideAnimeInfo];
	if(__showing_manga_info && [[[tabView selectedTabViewItem] view]isEqual:mangaTab])
		[self hideMangaInfo];
	
}

@end
