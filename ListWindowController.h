//
//  ListWindowController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iMAL_AppDelegate;
@class SearchWindowController;

@interface ListWindowController : NSWindowController {
	IBOutlet iMAL_AppDelegate * __app;	
	SearchWindowController * searchWindowController;
	
	IBOutlet NSView * targetView; // view targeted for switch
	NSViewController * currentViewController;
}

// TOOLBAR Actions
-(IBAction)showSearchPanel:(id)sender;
-(IBAction)refeshList:(id)sender;
-(IBAction)viewChoicePopupAction:(id)sender;

-(NSViewController*)viewController;

-(NSManagedObjectContext *)managedObjectContext;

@end
