//
//  MALNotificationsController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/18/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface MALNotificationsController : NSObject <GrowlApplicationBridgeDelegate> {

}

- (IBAction) denwaAction: (id) sender;

@end
