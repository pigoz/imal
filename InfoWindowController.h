//
//  InfoWindowController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InfoWindowController : NSWindowController {
	IBOutlet NSArrayController * __array_controller; /// array controller managing displayed anime/manga
}

-(IBAction)increaseEpisodeCount:(id)sender;

@end
