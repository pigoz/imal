//
//  ListWindowController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SearchWindowController;

@interface ListWindowController : NSWindowController {
	SearchWindowController * searchWindowController;
	
	IBOutlet NSView * targetView; // view targeted for switch
	NSViewController * currentViewController;
}

// TOOLBAR Actions
-(IBAction)showSearchPanel:(id)sender;
-(IBAction)viewChoicePopupAction:(id)sender;

-(NSViewController*)viewController;

@end
