//
//  MALNotificationsController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/18/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "MALNotificationsController.h"


@implementation MALNotificationsController


- (NSDictionary *) registrationDictionaryForGrowl{
	NSArray * n_all = [NSArray arrayWithObjects:@"KYON-KUN DENWA!!!", @"Scrobbled file", @"Added to list", nil];
	NSArray * n_default = [NSArray arrayWithObjects:@"KYON-KUN DENWA!!!", @"Scrobbled file", @"Added to list", nil];
	return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:n_all, n_default, nil]
									   forKeys:[NSArray arrayWithObjects:GROWL_NOTIFICATIONS_ALL, GROWL_NOTIFICATIONS_DEFAULT, nil]];
}

- (void) awakeFromNib
{
	[GrowlApplicationBridge setGrowlDelegate:self];
}

- (IBAction) denwaAction: (id) sender
{
	[GrowlApplicationBridge notifyWithTitle:@"KYON-KUN DENWA!!!" 
								description:@"Phone is ringing and iMAL is awesome!"
						   notificationName:@"KYON-KUN DENWA!!!" iconData:nil 
								   priority:0 isSticky:NO clickContext:nil];
}

@end
