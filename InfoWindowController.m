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

@synthesize __entry;
@synthesize shouldShow;

-(void)awakeFromNib
{
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	[self bind:@"shouldShow" toObject:defaults withKeyPath:@"values.shouldShowInfoPanel" options:nil];
	
	[self addObserver:self forKeyPath:@"__entry" 
							options:(NSKeyValueObservingOptionNew) context:NULL];
	
	//[(NSPanel *)self.window becomesKeyOnlyIfNeeded:YES];
}


-(void)updateVisibility
{
	if(__entry && shouldShow){
		[self showWindow:nil];
	} else {
		[self.window orderOut:nil];
	}
}

-(void)updateUIWithEntry:(Entry *)e
{
	if(e){
		[title setStringValue:[e imageTitle]];
		[subTitle setStringValue:[e imageSubtitle]];
		[status selectItemWithTag:[[e valueForKey:@"my_status"] intValue]];
		[rewatching setState:[[e valueForKey:@"my_rewatching"] intValue]];
		[episodes setStringValue:[[e valueForKey:@"episodes"] stringValue]];
		[my_episodes setStringValue:[[e valueForKey:@"my_episodes"] stringValue]];
	}
}

-(IBAction)cancel:(id)sender
{
	[self updateUIWithEntry:__entry];
}

-(void)editCallback
{
	[spinner setHidden:YES];
	[spinner stopAnimation:nil];
}

-(IBAction)edit:(id)sender
{
	[spinner startAnimation:nil];
	[spinner setHidden:NO];
	
	Entry * e = self.__entry;
	[e setValue:[NSNumber numberWithInt:[rewatching intValue]] forKey:@"my_rewatching"];
	[e setValue:[NSNumber numberWithInt:[my_episodes intValue]] forKey:@"my_episodes"];
	[e setValue:[NSNumber numberWithInt:[status selectedTag]] forKey:@"my_status"];
		
	NSMutableDictionary * values = [NSMutableDictionary new];
	[values setObject:[my_episodes stringValue] forKey:@"episode"];
	[values setObject:[rewatching stringValue] forKey:@"enable_rewatching"];
	[values setObject:[status stringValue] forKey:@"status"];
	
	PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(editCallback)] autorelease];
	MALHandler * mal = [MALHandler sharedHandler];
	[mal.queue addOperation:[[UpdateOperation alloc] initWithID:[[e valueForKey:@"id"] intValue] withType:[[e entity] name] values:values callback:cb]];
}

-(void)increaseEpisodeCallback:(Entry *)e
{
	int ep = [[e valueForKey:@"my_episodes"] intValue]+1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_episodes"];
}

-(void)increaseChapterCallback:(Entry *)e
{
	int ep = [[e valueForKey:@"my_chapters"] intValue]+1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_chapters"];
}

-(void)decreaseEpisodeCallback:(Entry *)e
{
	int ep = [[e valueForKey:@"my_episodes"] intValue]-1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_episodes"];
}

-(void)decreaseChapterCallback:(Entry *)e
{
	int ep = [[e valueForKey:@"my_chapters"] intValue]-1;
	[e setValue:[NSNumber numberWithInt:ep] forKey:@"my_chapters"];
}

-(IBAction)increaseEpisodeCount:(id)sender
{
	Entry * e = self.__entry;
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
	Entry * e = self.__entry;
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

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"__entry"]){
		[self updateVisibility];
		[self updateUIWithEntry:self.__entry];
	}
}

@end
