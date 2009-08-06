//
//  ListWindowController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "ListWindowController.h"
#import "SearchWindowController.h"

#import "AnimeListViewController.h"
#import "MangaListViewController.h"

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
			AnimeListViewController* animeListViewController =
			[[AnimeListViewController alloc] initWithNibName:@"AnimeList" bundle:nil];
			if (animeListViewController != nil)
			{
				
				currentViewController = animeListViewController;	// keep track of the current view controller
				[currentViewController setTitle:@"Anime"];
			}
			break;
		}
			
		case 1:	// swap in the "CustomTableViewController - NSTableView"
		{
			MangaListViewController* mangaListViewController =
			[[MangaListViewController alloc] initWithNibName:@"MangaList" bundle:nil];
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

-(IBAction)viewChoicePopupAction:(id)sender
{
	[self changeViewController: [[sender selectedCell] tag]];
}

- (void)awakeFromNib
{
	[self changeViewController: 0];
}
- (NSViewController*)viewController
{
	return currentViewController;
}

@end
