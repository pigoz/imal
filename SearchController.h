//
//  SearchController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/4/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SearchWindowController;

@interface SearchController : NSObject {
	SearchWindowController * searchWindowController;
}

-(IBAction) showSearchWindow:(id)sender;

@end
