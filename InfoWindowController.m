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
}


-(void)updateVisibility
{
	if(__entry && shouldShow){
		if(![self.window isVisible])
			[self.window orderFront:nil];
	} else {
		[self.window orderOut:nil];
	}
}

-(BOOL)windowShouldClose:(id)window
{
	if([window isEqual:self.window]){
		shouldShow = NO;
	}
	return YES;
}

-(void)updateUIWithEntry:(Entry *)e
{
	if (e && [[[e entity] name] isEqual:@"manga"]){
		[mangaTitle setStringValue:[e imageTitle]];
		[mangaSubTitle setStringValue:[e imageSubtitle]];
		[status selectItemWithTag:[[e valueForKey:@"my_status"] intValue]];
		[rereading setState:[[e valueForKey:@"my_rereading"] intValue]];
		[chapters setStringValue:[[e valueForKey:@"chapters"] stringValue]];
		[my_chapters setStringValue:[[e valueForKey:@"my_chapters"] stringValue]];
		[volumes setStringValue:[[e valueForKey:@"volumes"] stringValue]];
		[my_volumes setStringValue:[[e valueForKey:@"my_volumes"] stringValue]];
		[score selectItemWithTag:[[e valueForKey:@"score"] intValue]];
	}
	
	if(e && [[[e entity] name] isEqual:@"anime"]){
		[title setStringValue:[e imageTitle]];
		[subTitle setStringValue:[e imageSubtitle]];
		[status selectItemWithTag:[[e valueForKey:@"my_status"] intValue]];
		[rewatching setState:[[e valueForKey:@"my_rewatching"] intValue]];
		[episodes setStringValue:[[e valueForKey:@"episodes"] stringValue]];
		[my_episodes setStringValue:[[e valueForKey:@"my_episodes"] stringValue]];
		[score selectItemWithTag:[[e valueForKey:@"score"] intValue]];
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
	[manga_spinner setHidden:YES];
	[manga_spinner stopAnimation:nil];
	[self updateUIWithEntry:self.__entry];
}

-(IBAction)viewOnMAL:(id)sender
{
	NSString * url = [NSString stringWithFormat:@"http://myanimelist.net/%@/%@/", 
					 [[__entry entity] name],
					 [__entry valueForKey:@"id"]];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}
-(IBAction)editOnMAL:(id)sender
{
	NSString * url = [NSString stringWithFormat:@"http://myanimelist.net/panel.php?go=edit%@&id=%@", 
					  [[[__entry entity] name] isEqual:@"anime"] ? @"" : @"manga",
					  [__entry valueForKey:@"my_id"]];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

-(IBAction)edit:(id)sender
{
	[spinner startAnimation:nil];
	[spinner setHidden:NO];
	[manga_spinner startAnimation:nil];
	[manga_spinner setHidden:NO];
	
	NSMutableDictionary * values = [NSMutableDictionary new];
	if([[[__entry entity] name] isEqual:@"anime"]){
		[values setObject:[my_episodes stringValue] forKey:@"episode"];
		[values setObject:[rewatching stringValue] forKey:@"enable_rewatching"];
		[values setObject:[NSString stringWithFormat:@"%d", [status selectedTag]] forKey:@"status"];
		[values setObject:[NSString stringWithFormat:@"%d", [score selectedTag]] forKey:@"score"];
	} else {
		[values setObject:[my_chapters stringValue] forKey:@"chapter"];
		[values setObject:[my_volumes stringValue] forKey:@"volume"];
		[values setObject:[rereading stringValue] forKey:@"enable_rereading"];
		[values setObject:[NSString stringWithFormat:@"%d", [status selectedTag]] forKey:@"status"];
		[values setObject:[NSString stringWithFormat:@"%d", [score selectedTag]] forKey:@"score"];
	}
	
	PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(editCallback)] autorelease];
	MALHandler * mal = [MALHandler sharedHandler];
	[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:self.__entry values:values callback:cb] autorelease]];
}

-(IBAction)increaseEpisodeCount:(id)sender
{
	Entry * e = self.__entry;
	NSLog(@"%@", [e imageTitle]);
	MALHandler * mal = [MALHandler sharedHandler];
	NSMutableDictionary * values = [NSMutableDictionary new];
	if([[[e entity] name] isEqual:@"anime"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_episodes"] intValue]+1] forKey:@"episode"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(updateUIWithEntry:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:e values:values callback:cb] autorelease]];
	}
	if([[[e entity] name] isEqual:@"manga"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_chapters"] intValue]+1] forKey:@"chapter"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(updateUIWithEntry:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:e values:values callback:cb] autorelease]];
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
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(updateUIWithEntry:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:e values:values callback:cb] autorelease]];
	}
	if([[[e entity] name] isEqual:@"manga"]){
		[values setObject:[NSString stringWithFormat:@"%d", [[e valueForKey:@"my_chapters"] intValue]-1] forKey:@"chapter"];
		PGZCallback * cb = [[[PGZCallback alloc] initWithInstance:self selector:@selector(updateUIWithEntry:) argumentObject:e] autorelease];
		[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:e values:values callback:cb] autorelease]];
	}
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqual:@"__entry"]){
		[self updateVisibility];
		[self updateUIWithEntry:self.__entry];
	}
}

@end
