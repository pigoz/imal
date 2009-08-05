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

@synthesize __entries;


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
	[__entries_controller addObserver:self forKeyPath:@"selectedObjects" 
							  options:(NSKeyValueObservingOptionNew) 
							  context:NULL];
	showing_info = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willTerminate:)
												 name:NSApplicationWillTerminateNotification object:nil];
}

-(IBAction) searchAnime:(id) sender
{
	[animeSpinner startAnimation:nil];
	[animeSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * type = @"anime";
	PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(callback:)];
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:[animeSearchField stringValue] withType:type callback: [callback autorelease]]];
}

-(int) PopUpToMALStatus:(int)status
{
	switch (status)
	{
		case 4:	return MALPlantoWatch;
		default: return status-1;
	}
}

-(IBAction) addAnime:(id) sender
{
	[addAnimeSpinner startAnimation:nil];
	[addAnimeSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];

	SearchModel * sm = (SearchModel *)[[__entries_controller selectedObjects] objectAtIndex:0];
	NSMutableDictionary * values = [[NSMutableDictionary alloc] init];
	[values setObject:[NSString stringWithFormat:@"%@", [episodesField stringValue]] forKey:@"episode"];
	[values setObject:[NSString stringWithFormat:@"%d", [self PopUpToMALStatus:[[animeStatus selectedCell] tag]]] forKey:@"status"];
	
	PGZCallback * callback = [[PGZCallback alloc] initWithInstance:self selector:@selector(addAnimeCallback:)];
	[mal.queue addOperation:[[AddOperation alloc] initWithID:sm.__id withType:@"anime" values:values callback:callback]];
}

-(void) callback:(NSArray *) entries
{
	@synchronized(self){
		[self willChangeValueForKey:@"__entries"];
		[__entries release];
		__entries = [entries retain];
		[self didChangeValueForKey:@"__entries"];
		[animeSpinner stopAnimation:nil];
		[animeSpinner setHidden:YES];
	}
	
}

-(void) addAnimeCallback:(NSArray *) entries
{
	@synchronized(self){
		[addAnimeSpinner stopAnimation:nil];
		[addAnimeSpinner setHidden:YES];
	}
	
}

-(void)showInfo
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
	
	//[[self.window contentView] addSubview:infoView];
	[animeTab addSubview:animeInfoView];
	[animeTab addSubview:addAnime];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[animeScrollView setAutoresizingMask:mask];
	[animeScrollView setNextKeyView:episodesField];
	[episodesField setNextKeyView:animeSearchField];
	
	showing_info = YES;
}

-(void)hideInfo
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
	
	showing_info = NO;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"selectedObjects"]){
		SearchModel * sm = nil;
		if([[__entries_controller selectedObjects] count] > 0){
			sm = (SearchModel *)[[__entries_controller selectedObjects] objectAtIndex:0];
		}
		if(sm!=nil && showing_info == NO){
			[self showInfo];
		}
		if(sm==nil && showing_info == YES){
			[self hideInfo];
		}	
	}
}

- (void)willTerminate:(NSNotification *)notification
{
	if(showing_info)
		[self hideInfo];
}

@end
