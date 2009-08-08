//
//  ListViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "ListViewController.h"
#import "InfoWindowController.h"

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

-(void) awakeFromNib
{	
	// Add ourselves to end of the responder chain for this nib file
	[self.view setNextResponder:self];
	
	if([self.__type isEqual:@"anime"]){
		self.wrString = @"Watching";
		self.planString = @"Plan to Watch";
	}
	if([self.__type isEqual:@"manga"]){
		self.wrString = @"Reading";
		self.planString = @"Plan to Read";
	}
	
	/// IKImageBrowserView background
	CGFloat b = 38.0/255.0; // background
	[mImageBrowser setValue:[NSColor colorWithCalibratedRed:b green:b blue:b alpha:1.0] forKey:IKImageBrowserBackgroundColorKey];	
	
	/// Paragraph style for IKImageBrowserView titles/subtitles
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	/// IKImageBrowserView Titles
	CGFloat t = 220.0/255.0; // titles brightness
	NSMutableDictionary * attributes = [[NSMutableDictionary alloc] initWithCapacity:3]; 
	[attributes setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:12] forKey:NSFontAttributeName];
	[attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];    
	[attributes setObject:[NSColor colorWithDeviceRed:t green:t blue:t alpha:1] forKey:NSForegroundColorAttributeName];
	[mImageBrowser setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	[attributes release];
	
	/// IKImageBrowserView Subtitles
	CGFloat s = 180.0/255.0; // subtitles brightness
	NSMutableDictionary * s_attributes = [[NSMutableDictionary alloc] initWithCapacity:3]; 
	[s_attributes setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:10] forKey:NSFontAttributeName];
	[s_attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];    
	[s_attributes setObject:[NSColor colorWithDeviceRed:s green:s blue:s alpha:1] forKey:NSForegroundColorAttributeName];
	[mImageBrowser setValue:s_attributes forKey:IKImageBrowserCellsSubtitleAttributesKey];
	[s_attributes release];
	
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
	
	/// binding to NSUserDefaultsController
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	[self bind:@"watchingFlag" toObject:defaults withKeyPath:@"values.watchingFlag" options:nil];
	[self bind:@"completedFlag" toObject:defaults withKeyPath:@"values.completedFlag" options:nil];
	[self bind:@"holdFlag" toObject:defaults withKeyPath:@"values.holdFlag" options:nil];
	[self bind:@"droppedFlag" toObject:defaults withKeyPath:@"values.droppedFlag" options:nil];
	[self bind:@"planFlag" toObject:defaults withKeyPath:@"values.planFlag" options:nil];
	
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

/// seems like the IKImageBrowserView picks the wrong zoomValue, so I force a key-value change on awakeFromNib
-(void) refreshZoom
{
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	[[defaults values] setValue:[[defaults values] valueForKey:@"zoomValue"] forKey:@"zoomValue"];
}

-(void)constructPredicate
{
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

// overriding NSResponder keydown
- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"asd");
}

-(IBAction)showInfoPanel:(id)sender
{
	[infoPanelController showWindow:sender];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"watchingFlag"]||[keyPath isEqual:@"completedFlag"]||[keyPath isEqual:@"holdFlag"]||[keyPath isEqual:@"droppedFlag"]||[keyPath isEqual:@"planFlag"]){
		[self constructPredicate];
	}
	if([keyPath isEqual:@"searchString"]){
		[self constructPredicate];
	}
	if([keyPath isEqual:@"arrangedObjects.imageRepresentation"]){
		[mImageBrowser performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
	if([keyPath isEqual:@"arrangedObjects.imageSubtitle"]){
		[mImageBrowser performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
}
@end