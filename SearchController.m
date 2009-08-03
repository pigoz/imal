//
//  SearchController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "SearchController.h"
#import "MALHandler.h"
#import "SearchOperation.h"


@implementation SearchController

-(IBAction) search:(NSString *) query
{
	MALHandler * mal = [MALHandler sharedHandler];
	[mal.queue addOperation:[[SearchOperation alloc] initWithQuery:query withType:@"anime" 
														  callback:@selector(returnArray:)]];
	
}

-(void) returnArray:(NSArray *) returnArray
{
	@synchronized(self){
		[__entryNodes release];
		__entryNodes = [returnArray retain];
	}
}

-(int)numberOfRowsInTableView:(NSTableView *)tv
{
    return [__entryNodes count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    NSXMLNode *node = [itemNodes objectAtIndex:row];
    NSString *xPath = [tableColumn identifier];
    return [self stringForPath:xPath ofNode:node];
}

- (NSString *)stringForPath:(NSString *)xp ofNode:(NSXMLNode *)n
{
    NSError *error;
    NSArray *nodes = [n nodesForXPath:xp error:&error];
    if (!nodes) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        return nil;
    }
    if ([nodes count] == 0) {
        return nil;
    } else {
        return [[nodes objectAtIndex:0] stringValue];
    }
}

@end
