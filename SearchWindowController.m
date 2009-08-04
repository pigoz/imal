//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchWindowController.h"
#import "MALHandler.h"
#import "SearchOperation.h"
#import "SearchModel.h"


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
}

-(IBAction) searchAnime:(id) sender
{
	[animeSpinner startAnimation:nil];
	[animeSpinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * type = @"anime";
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:[animeSearchField stringValue] withType:type controller:self]];
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

-(void)showInfo
{
	NSRect bounds = [animeInfoView bounds];
	NSRect frame = [[self.window contentView] frame];
	NSRect w_frame = [self.window frame];
	
	w_frame.size.height += bounds.size.height;
	w_frame.origin.y -= bounds.size.height;
	
	// Locking the scrollview to the top 
	NSUInteger mask = [animeScrollView autoresizingMask]; // this was set in IB
	[animeScrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	[self.window setFrame:w_frame display:YES animate:YES];
	[animeInfoView setFrame:NSMakeRect(0.0, 0.0, frame.size.width, bounds.size.height)];
	
	//[[self.window contentView] addSubview:infoView];
	[animeTab addSubview:animeInfoView];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[animeScrollView setAutoresizingMask:mask];
	
	showing_info = YES;
}

-(void)hideInfo
{
	NSRect bounds = [animeInfoView bounds];
	NSRect w_frame = [self.window frame];
	
	w_frame.size.height -= bounds.size.height;
	w_frame.origin.y += bounds.size.height;

	
	// Locking the scrollview to the top 
	NSUInteger mask = [animeScrollView autoresizingMask]; // this was set in IB
	[animeScrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	
	[animeInfoView removeFromSuperview];
	[self.window setFrame:w_frame display:YES animate:YES];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[animeScrollView setAutoresizingMask:mask];
	
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

@end
