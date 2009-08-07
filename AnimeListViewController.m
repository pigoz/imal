//
//  AnimeListViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AnimeListViewController.h"


@implementation AnimeListViewController

@synthesize __db;
@synthesize __sort;
@synthesize zoomValue;
@synthesize watchingFlag;
@synthesize completedFlag;
@synthesize holdFlag;
@synthesize droppedFlag;
@synthesize planFlag;
@synthesize searchString;

-(void) awakeFromNib
{
	CGFloat f = 15.0/255.0;
	CGFloat s = 180.0/255.0;
	[mImageBrowser setValue:[NSColor colorWithCalibratedRed:f green:f blue:f alpha:1.0] forKey:IKImageBrowserBackgroundColorKey];
	//[mImageBrowser setValue:@"title" forKey:IKImageBrowserCellsTitleAttributesKey];
	
	
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	NSMutableDictionary * attributes = [[NSMutableDictionary alloc] initWithCapacity:3]; 
	
	[attributes setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:12] forKey:NSFontAttributeName];
	[attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];    
	[attributes setObject:[NSColor colorWithDeviceRed:s green:s blue:s alpha:1] forKey:NSForegroundColorAttributeName];
	[mImageBrowser setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	[attributes release];
	
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
	
	self.watchingFlag = YES;
	self.zoomValue = 0.62;
	//[self constructPredicate];
	
}

-(id)initWithContext:(NSManagedObjectContext *) db
{
	if(![super initWithNibName:@"AnimeList" bundle:nil])
		return nil;
	self.__db = db;
	self.__sort = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
	return self;
}

-(IBAction) zoomSliderDidChange:(id)sender
{
	[mImageBrowser setZoomValue:[sender floatValue]];
    [mImageBrowser setNeedsDisplay:YES];
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

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"watchingFlag"]||[keyPath isEqual:@"completedFlag"]||[keyPath isEqual:@"holdFlag"]||[keyPath isEqual:@"droppedFlag"]||[keyPath isEqual:@"planFlag"]){
		[self constructPredicate];
	}
	if([keyPath isEqual:@"searchString"]){
		[self constructPredicate];
	}
}
@end
