//
//  RecognitionPrefsViewController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "RecognitionPrefsViewController.h"


@implementation RecognitionPrefsViewController

- (NSString *)title
{
	return NSLocalizedString(@"Recognition", @"Title of 'Recognition' preference pane");
}

- (NSString *)identifier
{
	return @"RecognitionPane";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"NSAdvanced"];
}

@end
