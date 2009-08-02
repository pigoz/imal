//
//  PreferencesController.m
//  MBPreferencesController
//
//  Created by Stefano Pigozzi on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

#import "MBPreferencesController.h"
#import "GeneralPrefsViewController.h"
#import "MALPrefsViewController.h"

@implementation PreferencesController

- (void)awakeFromNib
{
	GeneralPrefsViewController *general = [[GeneralPrefsViewController alloc] initWithNibName:@"PreferencesGeneral" bundle:nil];
	MALPrefsViewController *mal = [[MALPrefsViewController alloc] initWithNibName:@"PreferencesMAL" bundle:nil];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:general, mal, nil]];
	[general release];
}

- (IBAction)showPreferences:(id)sender
{
	[[MBPreferencesController sharedController] showWindow:sender];
}

@end
