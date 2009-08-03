//
//  SearchController.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchController : NSObject {
	NSArray * __entryNodes;
	IBOutlet NSTableView * tableView;
	IBOutlet NSTextField * searchField;
	IBOutlet NSProgressIndicator * spinner;
}

-(IBAction) search:(id)sender;
-(void) callback:(NSArray *) returnArray;


-(int)numberOfRowsInTableView:(NSTableView *)tv;
-(id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
-(NSString *)stringForPath:(NSString *)xp ofNode:(NSXMLNode *)n;

@end
