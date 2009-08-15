//
//  AnimeRecognitionEngine.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AnimeRecognitionEngine.h"
#import "Entry.h";


@implementation AnimeRecognitionEngine

-(void)awakeFromNib
{
	[mph addObserver:self forKeyPath:@"playingPath" options:(NSKeyValueObservingOptionNew |
															   NSKeyValueObservingOptionOld) context:NULL];
}

- (NSString *) sanitize: (NSString *) string
{
	NSString * _sanitized_name;
	
	_sanitized_name = [string stringByMatching:@"(\\.mkv$|\\.avi$)" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\[.+?\\]" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\(.+?\\)" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"[\\_|\\-|\\.]" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\s\\s+" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"^\\s" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"v\\d+" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"(XviD|DivX|H264|H\\.264|h264|h\\.264|AVI|MP4|x264|x\\.264)" replace:50 withReferenceString:@""];
	
	return _sanitized_name;
} 

- (int) recognize: (NSString *)name
{
	NSManagedObjectContext *moc = [_app managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"anime" inManagedObjectContext:moc];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
		
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(my_status == 1)"];
	
	[request setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
		
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array == nil)
	{
		// Deal with error...
	}
	NSManagedObject * match = nil;
	NSRange max = NSMakeRange(0, 0);
	for(NSManagedObject * _e in array){
		NSRange range = [name rangeOfString:[_e valueForKey:@"title"]];
		if(range.location!=NSNotFound && range.length > max.length){
			max = range;
			match = _e;
		} else { // title did not match try alternatives
			NSArray * alternatives = [[_e valueForKey:@"synonyms"] componentsSeparatedByString:@";"];
			for(NSString *_a in alternatives){
				NSRange range = [name rangeOfString:_a];
				if(range.location!=NSNotFound && range.length > max.length){
					max = range;
					match = _e;
				}
			}
		}
	}
	if(match){
		NSLog(@"Recognized playing anime: ", [match valueForKey:@"title"]);
		return [[match valueForKey:@"id"] intValue];
	}
	return -1;
}

- (void) scrobble: (NSString *)path
{
	//NSString * _dir = ([path stringByMatching:@"(/.+/)" withReferenceFormat:@"$1"]);
	NSString * _f_name = ([path stringByMatching:@"/.+/(.+$)" withReferenceFormat:@"$1"]);
	NSLog(@"Detected file to recognize: %@", [self sanitize:_f_name]);
	[self recognize:[self sanitize:_f_name]];
	
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(![[change valueForKey:NSKeyValueChangeOldKey] isEqual:[change valueForKey:NSKeyValueChangeNewKey]] && [change valueForKey:NSKeyValueChangeNewKey])
		[self scrobble:[change valueForKey:NSKeyValueChangeNewKey]];
}

@end
