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

@synthesize increaseString;
@synthesize decreaseString;
@synthesize searchField;

-(IBAction)showSearchPanel:(id)sender
{
	@synchronized(self){
		if(!searchWindowController){
			searchWindowController = [[SearchWindowController alloc] initWithWindowNibName:@"SearchPanel"];
			searchWindowController.__db = [self managedObjectContext];
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
				self.increaseString = @"Increase episode count";
				self.decreaseString = @"Decrease episode count";
				[currentViewController setRepresentedObject:self]; // need to share the window
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
				self.increaseString = @"Increase chapter count";
				self.decreaseString = @"Decrease chapter count";
				[currentViewController setRepresentedObject:self]; // need to share the window
			}
			break;
		}
	}
	
	// embed the current view to our host view
	[targetView addSubview: [currentViewController view]];
	
	// make sure we automatically resize the controller's view to the current window size
	[[currentViewController view] setFrame: [targetView bounds]];
	
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
	NSString * title = [options valueForKey:@"title"];
	NSString * message = [options valueForKey:@"message"];
	if(title){
		[progressTitle setStringValue:title];
	}
	if(message){
		[progressMessage setStringValue:message];
	}
}

-(void)hideSheet
{
	[progressIndicator stopAnimation:self];
	[progressSheet orderOut:nil];
	[NSApp endSheet:progressSheet];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([toolbarItem tag] == 13) // Info
		return [[currentViewController.__array_controller selectedObjects] count] > 0;
	return YES;
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
	PGZCallback * update = [[PGZCallback alloc] initWithInstance:self selector:@selector(updateSheet:)];
	PGZCallback * done = [[PGZCallback alloc] initWithInstance:self selector:@selector(hideSheet)];
	if([[showingList selectedCell] tag] == 0 ){
		[mal.queue addOperation:[[RefreshOperation alloc] initWithType:@"anime" context:[__app managedObjectContext] start:start update:update done:done]];
	} else {
		[mal.queue addOperation:[[RefreshOperation alloc] initWithType:@"manga" context:[__app managedObjectContext] start:start update:update done:done]];
	}
}

-(IBAction)search:(id)sender
{
	[currentViewController setValue:[sender stringValue] forKey: @"searchString"];
}

-(IBAction)increaseEp:(id)sender
{
	[currentViewController increaseEp:sender];
}

-(IBAction)decreaseEp:(id)sender
{
	[currentViewController decreaseEp:sender];
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
