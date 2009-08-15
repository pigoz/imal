//
//  AnimeRecognitionEngine.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPlayerHandler.h"
#import "iMAL_AppDelegate.h"

@interface AnimeRecognitionEngine : NSObject {
	IBOutlet iMAL_AppDelegate * _app;
	IBOutlet MPlayerHandler * mph;
}

@end
