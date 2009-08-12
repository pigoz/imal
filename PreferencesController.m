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

+ (void) initialize
{
	// Create directory to cache images
	NSFileManager * fm = [NSFileManager defaultManager];
	NSString * anime_path = [NSString stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/anime",NSUserName()];
	NSString * manga_path = [NSString stringWithFormat:@"/Users/%@/Library/Application Support/iMAL/images/manga",NSUserName()];
	if(![fm fileExistsAtPath:anime_path])
		[fm createDirectoryAtPath:anime_path withIntermediateDirectories:YES attributes:nil error:NULL];
	if(![fm fileExistsAtPath:manga_path])
		[fm createDirectoryAtPath:manga_path withIntermediateDirectories:YES attributes:nil error:NULL];
	
	// Register defaults
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:@"http://myanimelist.net/api" forKey:@"mal_api_address"];
	[defaultValues setObject:[NSNumber numberWithFloat:0.5] forKey:@"zoomValue"];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:@"watchingFlag"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

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
