//
//  MALPrefsViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MALPrefsViewController.h"


@implementation MALPrefsViewController

- (NSString *)title
{
	return NSLocalizedString(@"MAL Account", @"Title of 'MAL Preferences' preference pane");
}

- (NSString *)identifier
{
	return @"MALPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSDotMac"];
}

- (IBAction) test:(id)sender{
	NSUserDefaults * preferences = [NSUserDefaults standardUserDefaults];
	NSLog(@"%@, %@",[preferences stringForKey:@"mal_username"], [preferences stringForKey:@"mal_password"]);
}

@end
