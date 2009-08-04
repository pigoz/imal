//
//  NSXMLNode+stringForXPath.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/4/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "NSXMLNode+stringForXPath.h"


@implementation NSXMLNode (stringForXPath)

-(NSString *)stringForXPath:(NSString *)xp
{
	NSError *error;
    NSArray *nodes = [self nodesForXPath:xp error:&error];
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
