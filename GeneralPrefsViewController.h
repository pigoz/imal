//
//  GeneralPrefsViewController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBPreferencesController.h"

@interface GeneralPrefsViewController : NSViewController <MBPreferencesModule> {

}

- (NSString *)identifier;
- (NSImage *)image;

@end
