//
//  RecognitionPrefsViewController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface RecognitionPrefsViewController : NSViewController <MBPreferencesModule> {
	
}

- (NSString *)identifier;
- (NSImage *)image;

@end
