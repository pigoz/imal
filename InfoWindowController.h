//
//  InfoWindowController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Entry.h"

@interface InfoWindowController : NSWindowController {
	
	IBOutlet NSTextField * title;
	IBOutlet NSTextField * subTitle;
	IBOutlet NSPopUpButton * status;
	IBOutlet NSPopUpButton * score;
	
	IBOutlet NSButton * rewatching;
	IBOutlet NSTextField * episodes;
	IBOutlet NSTextField * my_episodes;
	
	IBOutlet NSProgressIndicator * spinner;
	
	Entry * __entry;
	
	BOOL shouldShow;
}

@property (retain) Entry * __entry;
@property (assign) BOOL shouldShow;

-(void)updateVisibility;
-(IBAction)increaseEpisodeCount:(id)sender;
-(IBAction)decreaseEpisodeCount:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)edit:(id)sender;

@end
