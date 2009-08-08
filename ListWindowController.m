//
//  ListWindowController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "ListWindowController.h"
#import "SearchWindowController.h"

#import "ListViewController.h"

#import "iMAL_AppDelegate.h"
#import "MALHandler.h"
#import "RefreshOperation.h"

#import "PGZCallback.h"


@implementation ListWindowController

-(IBAction)showSearchPanel:(id)sender
{
	@synchronized(self){
		if(!searchWindowController){
			searchWindowController = [[SearchWindowController alloc] initWithWindowNibName:@"SearchPanel"];
		}
	}
	[searchWindowController showWindow:self];
}

-(IBAction)showInfoPanel:(id)sender
{
	[currentViewController showInfoPanel:sender];
}

-(void)changeViewController:(NSInteger)whichViewTag
{
	// we are about to change the current view controller,
	// this prepares our title's value binding to change with it
	[self willChangeValueForKey:@"viewController"];
	
	if ([currentViewController view] != nil)
		[[currentViewController view] removeFromSuperview];	// remove the current view
	
	if (currentViewController != nil)
		[currentViewController release];		// remove the current view controller
	
	switch (whichViewTag)
	{
		case 0:	// swap in the "AnimeListViewController"
		{
			ListViewController* animeListViewController =
			[[ListViewController alloc] initWithType:@"anime" context:[__app managedObjectContext]];
			if (animeListViewController != nil)
			{
				
				currentViewController = animeListViewController;	// keep track of the current view controller
				[currentViewController setTitle:@"Anime"];
			}
			break;
		}
			
		case 1:	// swap in the "CustomTableViewController - NSTableView"
		{
			ListViewController* mangaListViewController =
			[[ListViewController alloc] initWithType:@"manga" context:[__app managedObjectContext]];
			if (mangaListViewController != nil)
			{
				
				currentViewController = mangaListViewController;	// keep track of the current view controller
				[currentViewController setTitle:@"Manga"];
			}
			break;
		}
	}
	
	// embed the current view to our host view
	[targetView addSubview: [currentViewController view]];
	
	// make sure we automatically resize the controller's view to the current window size
	[[currentViewController view] setFrame: [targetView bounds]];
	
	// set the view controller's represented object to the number of subviews in that controller
	// (our NSTextField's value binding will reflect this value)
	[currentViewController setRepresentedObject: [NSNumber numberWithUnsignedInt: [[[currentViewController view] subviews] count]]];
	
	[self didChangeValueForKey:@"viewController"];	// this will trigger the NSTextField's value binding to change
}

-(void)showSheet
{
	[NSApp beginSheet:progressSheet modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[progressIndicator setUsesThreadedAnimation:YES];
	[progressIndicator startAnimation:self];
}

-(void)updateSheet:(NSDictionary *)options
{
	//NSString * title = [options valueForKey:@"title"];
	//NSString * message = [options valueForKey:@"title"];
}

-(void)hideSheet
{
	[progressIndicator stopAnimation:self];
	[progressSheet orderOut:nil];
	[NSApp endSheet:progressSheet];
}

-(IBAction)cancelProgressAction:(id)sender
{
	MALHandler * mal = [MALHandler sharedHandler];
	[mal.queue cancelAllOperations]; //cancel waiting operations
	[[__app managedObjectContext] rollback]; //rolls back to last save NOTE: save occurs before import.
	[self hideSheet];
}

-(IBAction)viewChoicePopupAction:(id)sender
{
	[self changeViewController: [[sender selectedCell] tag]];
}

-(IBAction)refeshList:(id)sender
{
	NSError * error;
	[[__app managedObjectContext] save:&error];
	MALHandler * mal = [MALHandler sharedHandler];
	PGZCallback * start = [[PGZCallback alloc] initWithInstance:self selector:@selector(showSheet)];
	PGZCallback * done = [[PGZCallback alloc] initWithInstance:self selector:@selector(hideSheet)];
	if([[showingList selectedCell] tag] == 0 ){
		[mal.queue addOperation:[[RefreshOperation alloc] initWithType:@"anime" context:[__app managedObjectContext] start:start done:done]];
	} else {
		[mal.queue addOperation:[[RefreshOperation alloc] initWithType:@"manga" context:[__app managedObjectContext] start:start done:done]];
	}
}

-(IBAction)search:(id)sender
{
	[currentViewController setValue:[sender stringValue] forKey: @"searchString"];
}

- (void)awakeFromNib
{
	[self viewChoicePopupAction:showingList];
}
- (ListViewController*)viewController
{
	return currentViewController;
}
-(NSManagedObjectContext *)managedObjectContext
{
	return [__app managedObjectContext];
}

@end
