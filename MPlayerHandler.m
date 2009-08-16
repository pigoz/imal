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
	NSUserDefaultsController * defaults = [NSUserDefaultsController sharedUserDefaultsController];
	NSMutableArray * paths = [[[NSMutableArray alloc] init] autorelease];
	
	BOOL only_rec_paths = [[defaults.values valueForKey:@"recognizedPathsOnly"] boolValue];
	
	if(only_rec_paths)
	for(NSMutableDictionary * d in [defaults.values valueForKey:@"preferencesAnimePaths"]){
		NSString * path = [d valueForKey:@"path"];
		if(path && [[NSFileManager defaultManager] fileExistsAtPath:path]){
			[paths addObject:[[path copy] autorelease]];
		}
	}
	
	NSTask *lsof = [[[NSTask alloc] init] autorelease];
	NSTask *grep = [[[NSTask alloc] init] autorelease];
	NSTask *grep2 = [[[NSTask alloc] init] autorelease];
	
	// lsof task
	[lsof setLaunchPath:@"/usr/sbin/lsof"];
	[lsof setArguments:[NSArray arrayWithObjects:@"-c", @"mplayer", @"-F", @"n", nil]];
	
	//grep task
	[grep setLaunchPath:@"/usr/bin/grep"];
	[grep setArguments:[NSArray arrayWithObjects:@"-e", @".mkv$", @"-e", @".avi$",nil]];
	
	// grep2 task
	[grep2 setLaunchPath:@"/usr/bin/egrep"];
	[grep2 setArguments:[NSArray arrayWithObjects:@"-v", @"(OP|ED|Teaser)", nil]]; // will not report openings and endings, 
																	//which get reported if you have mplayer with ordered chapters
	
	// lets pipe lsof | grep | grep
	NSPipe * pipe = [NSPipe pipe];
	[lsof setStandardOutput:pipe];
	[grep setStandardInput:pipe];
	
	NSPipe * pipe_b = [NSPipe pipe];
	[grep setStandardOutput:pipe_b];
	[grep2 setStandardInput:pipe_b];
	
	[lsof setStandardError:[NSFileHandle fileHandleWithNullDevice]]; // we dont need errors!
	[grep2 setStandardOutput:[NSPipe pipe]];
	
	[lsof launch];
	[grep launch];
	[grep2 launch];
	 	
	NSData *data = [[[grep2 standardOutput] fileHandleForReading] readDataToEndOfFile];
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	NSString *path = [string stringByMatching:@"^n" replace:1 withReferenceFormat:@""];
		
	if(path && ![path isEqual:@""]){
		BOOL detected = YES;
		if(only_rec_paths){
			detected = NO;
			for(NSString * default_path in paths)
				if([path rangeOfString:default_path].location!=NSNotFound) detected = YES;
		}
		if(detected){
			#ifdef DEBUG
			NSLog([NSString stringWithFormat:@"Detected file playing: %@", path]);
			#endif
			self.playingPath = path;
		}
	} else {
		self.playingPath = nil;
	}
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
