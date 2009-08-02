//
//  GeneralPrefsViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GeneralPrefsViewController.h"


@implementation GeneralPrefsViewController

- (NSString *)title
{
	return NSLocalizedString(@"General", @"Title of 'General' preference pane");
}

- (NSString *)identifier
{
	return @"TestGeneralPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

@end
