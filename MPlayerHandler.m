//
//  MPlayerHandler.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "MPlayerHandler.h"


@implementation MPlayerHandler
@synthesize playingPath;

-(void) sample
{
	NSTask *lsof = [[[NSTask alloc] init] autorelease];
	NSTask *grep = [[[NSTask alloc] init] autorelease];
	
	// lsof task
	[lsof setLaunchPath:@"/usr/sbin/lsof"];
	// TODO Build a preference pane with directories
	[lsof setArguments:[NSArray arrayWithObjects:@"-c", @"mplayer", @"+D", @"/Users/stefano/Movies/", @"+D", @"/Volumes/external#1/", @"-F", @"n", nil]];
	
	// grep task
	[grep setLaunchPath:@"/usr/bin/grep"];
	[grep setArguments:[NSArray arrayWithObjects:@"-e", @".mkv$", @"-e", @".avi$",nil]];
	
	// lets pipe lsof | grep
	NSPipe * pipe = [NSPipe pipe];
	[lsof setStandardOutput:pipe];
	[grep setStandardInput:pipe];
	
	[lsof setStandardError:[NSFileHandle fileHandleWithNullDevice]]; // we dont need errors!
	[grep setStandardOutput:[NSPipe pipe]];
	
	[lsof launch];
	[grep launch];
	 	
	NSData *data = [[[grep standardOutput] fileHandleForReading] readDataToEndOfFile];
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	NSString *path = [string stringByMatching:@"^n" replace:1 withReferenceFormat:@""];
	
	if(path && ![path isEqual:@""])
		self.playingPath = [string stringByMatching:@"^n" replace:1 withReferenceFormat:@""];
	else
		self.playingPath = nil;
	
	#ifdef DEBUG
	if(self.playingPath) NSLog([NSString stringWithFormat:@"Detected file playing: %@", self.playingPath]);
	#endif
	
	[self performSelector:@selector(sample) withObject:nil afterDelay: 10];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self performSelector:@selector(sample) withObject:nil afterDelay: 10];
	}
	return self;
}


@end
