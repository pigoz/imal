//
//  ListViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "ListViewController.h"
#import "InfoWindowController.h"
#import "ListWindowController.h"
#import "MALHandler.h"

@implementation ListViewController

@synthesize __db;
@synthesize __type;
@synthesize __sort;
@synthesize watchingFlag;
@synthesize completedFlag;
@synthesize holdFlag;
@synthesize droppedFlag;
@synthesize planFlag;
@synthesize searchString;

@synthesize wrString;
@synthesize planString;

@synthesize __array_controller;

@synthesize mImageBrowser;

-(void) awakeFromNib
{	
	// Add ourselves to end of the responder chain for this nib file
	//[self.view setNextResponder:self];
	
	if([self.__type isEqual:@"anime"]){
		self.wrString = @"Watching";
		self.planString = @"Plan to Watch";
	}
	if([self.__type isEqual:@"manga"]){
		self.wrString = @"Reading";
		self.planString = @"Plan to Read";
	}
	
	/// Observing self for predicate change on NSArrayController
	[self addObserver:self forKeyPath:@"watchingFlag" options:(NSKeyValueObservingOptionNew |
															   NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"completedFlag" options:(NSKeyValueObservingOptionNew |
																NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"holdFlag" options:(NSKeyValueObservingOptionNew |
														   NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"droppedFlag" options:(NSKeyValueObservingOptionNew |
															  NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"planFlag" options:(NSKeyValueObservingOptionNew |
														   NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"searchString" options:(NSKeyValueObservingOptionNew |
															   NSKeyValueObservingOptionOld) context:NULL];
	
	/// binding filters state to NSUserDefaultsController
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	[self bind:@"watchingFlag" toObject:defaults withKeyPath:@"values.watchingFlag" options:nil];
	[self bind:@"completedFlag" toObject:defaults withKeyPath:@"values.completedFlag" options:nil];
	[self bind:@"holdFlag" toObject:defaults withKeyPath:@"values.holdFlag" options:nil];
	[self bind:@"droppedFlag" toObject:defaults withKeyPath:@"values.droppedFlag" options:nil];
	[self bind:@"planFlag" toObject:defaults withKeyPath:@"values.planFlag" options:nil];
	
	[defaults addObserver:self forKeyPath:@"values.zoomValue" options:(NSKeyValueObservingOptionNew) context:nil];
	
	/// IKImageBrowserView background, for text styling => -(void) imageTextZoom:(float) zoom
	CGFloat b = 38.0/255.0; // background
	[mImageBrowser setValue:[NSColor colorWithCalibratedRed:b green:b blue:b alpha:1.0] forKey:IKImageBrowserBackgroundColorKey];	
	
	
	/// entity managed by nsarraycontroller
	[__array_controller setEntityName:self.__type];
	
	/// observe changing properties
	[__array_controller addObserver:self forKeyPath:@"arrangedObjects.imageRepresentation" 
			  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[__array_controller addObserver:self forKeyPath:@"arrangedObjects.imageSubtitle" 
							options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];

	// refreshes the IKImageBrowserView
	[self performSelector:@selector(refreshZoom) withObject:nil afterDelay:0.0];
	[self constructPredicate];
	
	// image browser first responder, next key => search field
	[[[self representedObject] window] makeFirstResponder:mImageBrowser];
	
	if([self.__type isEqual:@"anime"]){
		infoPanelController = [[InfoWindowController alloc] initWithWindowNibName:@"InfoPanel"];
		[infoPanelController loadWindow];
		[__array_controller addObserver:self forKeyPath:@"selectedObjects" 
								options:(NSKeyValueObservingOptionNew) context:NULL];
	} else {
		// TODO infoPanel for mangas
	}

}

-(id)initWithType:(NSString*) type context:(NSManagedObjectContext *) db
{
	if(![super initWithNibName:@"ListView" bundle:nil])
		return nil;
	self.__type = type;
	self.__db = db;
	self.__sort = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
	return self;
}

// sets a good text styling based on the zoom
-(void) imageTextZoom:(float) zoom
{
	int t_size;
	int st_size;
	
	if(zoom <= 1.0){
		t_size = 12;
		st_size = 10;
	}
	if(zoom < 0.6){
		t_size = 11;
		st_size = 9;
	}
	if(zoom < 0.4){
		t_size = 10;
		st_size = 8;
	}
	if(zoom < 0.2){
		t_size = 9;
		st_size = 7;
	}
	
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	/// IKImageBrowserView Titles
	CGFloat t = 220.0/255.0; // titles brightness
	NSMutableDictionary * attributes = [[NSMutableDictionary alloc] initWithCapacity:3]; 
	[attributes setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:t_size] forKey:NSFontAttributeName];
	[attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];    
	[attributes setObject:[NSColor colorWithDeviceRed:t green:t blue:t alpha:1] forKey:NSForegroundColorAttributeName];
	[mImageBrowser setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	[attributes release];
	
	/// IKImageBrowserView Subtitles
	CGFloat s = 180.0/255.0; // subtitles brightness
	NSMutableDictionary * s_attributes = [[NSMutableDictionary alloc] initWithCapacity:3]; 
	[s_attributes setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:st_size] forKey:NSFontAttributeName];
	[s_attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];    
	[s_attributes setObject:[NSColor colorWithDeviceRed:s green:s blue:s alpha:1] forKey:NSForegroundColorAttributeName];
	[mImageBrowser setValue:s_attributes forKey:IKImageBrowserCellsSubtitleAttributesKey];
	[s_attributes release];
}

/// seems like the IKImageBrowserView picks the wrong zoomValue, so I force a key-value change on awakeFromNib
-(void) refreshZoom
{
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	[[defaults values] setValue:[[defaults values] valueForKey:@"zoomValue"] forKey:@"zoomValue"];
}

-(void)constructPredicate
{
	MALHandler * mal = [MALHandler sharedHandler];
	[mal.dl_queue cancelAllOperations]; // this is to keep downloading first the images we are currently displaying
	mal.dl_queue = [NSOperationQueue new];
	[mal.dl_queue setMaxConcurrentOperationCount:2];
	
	NSString * _search_pred = nil;
	if(searchString) 
		_search_pred = [NSString stringWithFormat:@"(title like[c] \"*%@*\") OR (synonyms like[c] \"*%@*\")", searchString, searchString];
	
	NSString * _pred = @"";
	if(watchingFlag) _pred = [NSString stringWithFormat:@"%@ OR (my_status == 1)", _pred];
	if(completedFlag) _pred = [NSString stringWithFormat:@"%@ OR (my_status == 2)", _pred];
	if(holdFlag) _pred = [NSString stringWithFormat:@"%@ OR (my_status == 3)", _pred];
	if(droppedFlag) _pred = [NSString stringWithFormat:@"%@ OR (my_status == 4)", _pred];
	if(planFlag) _pred = [NSString stringWithFormat:@"%@ OR (my_status == 6)", _pred];
	_pred = [_pred stringByMatching:@"^ OR " replace: 1 withReferenceString:@""];
	if([_pred isEqual:@""]) _pred = @"(my_status == 0)";
	
	NSString * _and_pred = nil;
	if(_pred && _search_pred){
		_and_pred = [NSString stringWithFormat:@"(%@) AND (%@)", _pred, _search_pred];
	} else {
		if(_pred) _and_pred = _pred;
		if(_search_pred) _and_pred = _search_pred;
	}
	
	[__array_controller setFilterPredicate:[NSPredicate predicateWithFormat:_and_pred]];	
}

-(IBAction)showInfoPanel:(id)sender
{
	//[infoPanelController showWindow:sender];
	infoPanelController.shouldShow = !infoPanelController.shouldShow;
	[infoPanelController updateVisibility];
}

-(IBAction)increaseEp:(id)sender
{
	[infoPanelController increaseEpisodeCount:sender];
}

-(IBAction)decreaseEp:(id)sender
{
	[infoPanelController decreaseEpisodeCount:sender];
}

 -(void) dealloc
{
	[infoPanelController.window orderOut:nil];
	[infoPanelController release];
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	[defaults removeObserver:self forKeyPath:@"values.zoomValue"];
	[super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"watchingFlag"]||[keyPath isEqual:@"completedFlag"]||[keyPath isEqual:@"holdFlag"]||[keyPath isEqual:@"droppedFlag"]||[keyPath isEqual:@"planFlag"]){
		[self constructPredicate];
		return;
	}
	if([keyPath isEqual:@"searchString"]){
		[self constructPredicate];
		return;
	}
	if([keyPath isEqual:@"selectedObjects"]){
		if([[__array_controller selectedObjects] count] > 0)
			infoPanelController.__entry = [[__array_controller selectedObjects] objectAtIndex:0];
		else
			infoPanelController.__entry = nil;
		return;
	}
	if([keyPath isEqual:@"values.zoomValue"]){
		[self imageTextZoom:[[[object defaults] valueForKey:@"zoomValue"] floatValue]];
		return;
	}
	if([keyPath isEqual:@"arrangedObjects.imageRepresentation"]){
		[mImageBrowser performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
		return;
	}
	if([keyPath isEqual:@"arrangedObjects.imageSubtitle"]){
		[mImageBrowser performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
		return;
	}
}
@end