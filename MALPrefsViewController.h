//
//  MALPrefsViewController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface MALPrefsViewController : NSViewController <MBPreferencesModule> {

}

- (IBAction) test:(id)sender;
- (NSString *)identifier;
- (NSImage *)image;

@end
