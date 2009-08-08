//
//  InfoWindowController.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/8/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "InfoWindowController.h"
#import "Entry.h"
#import "MALHandler.h"
#import "PGZCallback.h"
#import "UpdateOperation.h"

@implementation InfoWindowController

-(void)increaseEpisodeCallback:(Entry *)e
{
	[e willChangeValueForKey:@"imageSubtitle"];
	int ep = [[e valueForKey:@"my_episodes"] intValue]+1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_episodes"];
	[e didChangeValueForKey:@"imageSubtitle"];
}

-(void)increaseChapterCallback:(Entry *)e
{
	[e willChangeValueForKey:@"imageSubtitle"];
	int ep = [[e valueForKey:@"my_chapters"] intValue]+1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_chapters"];
	[e didChangeValueForKey:@"imageSubtitle"];
}

-(void)decreaseEpisodeCallback:(Entry *)e
{
	[e willChangeValueForKey:@"imageSubtitle"];
	int ep = [[e valueForKey:@"my_episodes"] intValue]-1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_episodes"];
	[e didChangeValueForKey:@"imageSubtitle"];
}

-(void)decreaseChapterCallback:(Entry *)e
{
	[e willChangeValueForKey:@"imageSubtitle"];
	int ep = [[e valueForKey:@"my_chapters"] intValue]-1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_chapters"];
	[e didChangeValueForKey:@"imageSubtitle"];
}

-(IBAction)increaseEpisodeCount:(id)sender
{
	Entry * e = [[__array_controller selectedObjects] objectAtIndex:0];
	NSLog(@"%@", [e imageTitle]);
	MALHandler * mal = [MALHandler sharedHandler];
	NSMutableDictionary * values = [NSMutableDictionary new];
	if([[[e entity] name] isEqual:@"anime"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_episodes"] intValue]+1] forKey:@"episode"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(increaseEpisodeCallback:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[UpdateOperation alloc] initWithID:[[e valueForKey:@"id"] intValue] withType:[[e entity] name] values:values callback:cb]];
	}
	if([[[e entity] name] isEqual:@"manga"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_chapters"] intValue]+1] forKey:@"chapter"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(increaseChapterCallback:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[UpdateOperation alloc] initWithID:[[e valueForKey:@"id"] intValue] withType:[[e entity] name] values:values callback:cb]];
	}
}

-(IBAction)decreaseEpisodeCount:(id)sender
{
	Entry * e = [[__array_controller selectedObjects] objectAtIndex:0];
	NSLog(@"%@", [e imageTitle]);
	MALHandler * mal = [MALHandler sharedHandler];
	NSMutableDictionary * values = [NSMutableDictionary new];
	if([[[e entity] name] isEqual:@"anime"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_episodes"] intValue]-1] forKey:@"episode"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(decreaseEpisodeCallback:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[UpdateOperation alloc] initWithID:[[e valueForKey:@"id"] intValue] withType:[[e entity] name] values:values callback:cb]];
	}
	if([[[e entity] name] isEqual:@"manga"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_chapters"] intValue]-1] forKey:@"chapter"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(decreaseChapterCallback:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[UpdateOperation alloc] initWithID:[[e valueForKey:@"id"] intValue] withType:[[e entity] name] values:values callback:cb]];
	}
}

@end
