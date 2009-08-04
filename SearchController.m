//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchController.h"
#import "MALHandler.h"
#import "SearchOperation.h"
#import "SearchModel.h"


@implementation SearchController

@synthesize __entries;

-(void)awakeFromNib
{
	// observe the selection
	[__entries_controller addObserver:self forKeyPath:@"selectedObjects" 
							  options:(NSKeyValueObservingOptionNew) 
							  context:NULL];
	showing_info = NO;
}

-(IBAction) search:(id)sender
{
	[spinner startAnimation:nil];
	[spinner setHidden:NO];
	MALHandler * mal = [MALHandler sharedHandler];
	NSString * type = @"anime";
	if([[popupButton objectValue] intValue]==1)
		type = @"manga";
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:[searchField stringValue] withType:type controller:self]];
	
}
-(void) callback:(NSArray *) entries
{
	@synchronized(self){
		[self willChangeValueForKey:@"__entries"];
		[__entries release];
		__entries = [entries retain];
		[self didChangeValueForKey:@"__entries"];
		[spinner stopAnimation:nil];
		[spinner setHidden:YES];
	}
	
}

-(NSRect)newFrameForNewContentView:(NSView *)view {
    NSWindow *window = searchWindow;
    NSRect newFrameRect = [window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
	frame.origin.x -= (newSize.width - oldSize.width)/2;
    
    return frame;
}

-(void)showInfo
{
	NSRect bounds = [infoView bounds];
	NSRect frame = [[searchWindow contentView] frame];
	NSRect w_frame = [searchWindow frame];
	
	w_frame.size.height += bounds.size.height;
	w_frame.origin.y -= bounds.size.height;
	
	// Locking the scrollview to the top 
	NSUInteger mask = [scrollView autoresizingMask]; // this was set in IB
	[scrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	[searchWindow setFrame:w_frame display:YES animate:YES];
	[infoView setFrame:NSMakeRect(0.0, 0.0, frame.size.width, bounds.size.height)];
	
	[[searchWindow contentView] addSubview:infoView];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[scrollView setAutoresizingMask:mask];
	
	showing_info = YES;
}

-(void)hideInfo
{
	NSRect bounds = [infoView bounds];
	NSRect w_frame = [searchWindow frame];
	
	w_frame.size.height -= bounds.size.height;
	w_frame.origin.y += bounds.size.height;

	
	// Locking the scrollview to the top 
	NSUInteger mask = [scrollView autoresizingMask]; // this was set in IB
	[scrollView setAutoresizingMask:NSViewMinYMargin];
	
	[NSAnimationContext beginGrouping];
	
	[infoView removeFromSuperview];
	[searchWindow setFrame:w_frame display:YES animate:YES];
	[NSAnimationContext endGrouping];
	
	// Making the scrollview autoresize again in all directions.
	[scrollView setAutoresizingMask:mask];
	
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
