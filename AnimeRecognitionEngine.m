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

- (NSArray *) allAnime
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
	return array;
}

- (NSArray *) allAnimeWithTrigrams:(NSArray *) trigrams
{
	NSManagedObjectContext *moc = [_app managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"trigram" inManagedObjectContext:moc];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tg IN %@", trigrams];
	
	[request setPredicate:predicate];
	//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"anime" ascending:YES];
	//[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	//[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	return array;
}

- (void) insertSortedinArray:(NSMutableArray *)a anime:(NSDictionary *) d
{
	int idx = 0;
	for(NSDictionary * e in a){
		if([[d valueForKey:@"score"] intValue] > [[e valueForKey:@"score"] intValue]){
			[a insertObject:d atIndex:idx];
			return;
		}
		idx++;
	}
	[a insertObject:d atIndex:[a count]];
	return;
}

- (int) recognizetg: (NSString *)name
{
	NSMutableArray * tgs = [[[NSMutableArray alloc] init] autorelease];
	NSArray * words = [name componentsSeparatedByString:@" "];
	for(NSString * word in words){
		word = [@" " stringByAppendingString:word]; // this way the first trigram will notice it is a word start
		if([word length]>=3)
			for(int idx = 0; idx <= [word length]-3; idx++){
				[tgs addObject: [word substringWithRange:NSMakeRange(idx, 3)]]; //trigram
			}
	}
	
	// will do group by myself since core data sucks
	NSMutableArray * animes = [[NSMutableArray alloc] init];
//	Entry * cur = nil;
//	int score_sum = 0;
	NSArray * animes_tgs = [self allAnimeWithTrigrams:tgs];
	for(NSManagedObject * o in animes_tgs){
		Entry * e = [o valueForKey:@"anime"];

		BOOL found = NO;
		NSMutableArray * cur;
		for(NSMutableArray * temp in animes){
			cur = temp;
			if([[temp objectAtIndex:0] isEqual:e]){
				found = YES; break;
			}
		}
		
		if(found){
			int score = [[o valueForKey:@"score"] intValue] + [[cur objectAtIndex:1] intValue];
			[cur removeObjectAtIndex:1];
			[cur insertObject:[NSNumber numberWithInt:score] atIndex:1];
		} else {
			[animes insertObject:[NSMutableArray arrayWithObjects:e, [o valueForKey:@"score"]] atIndex:[animes count]];
		}
	}
	
	NSLog(@"%@", [animes objectAtIndex:0]);
	
	return 1;
}

- (int) recognize: (NSString *)name
{
	NSArray * array = [self allAnime];
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
	[self recognizetg:[self sanitize:_f_name]];
	
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(![[change valueForKey:NSKeyValueChangeOldKey] isEqual:[change valueForKey:NSKeyValueChangeNewKey]] && [change valueForKey:NSKeyValueChangeNewKey])
		[self scrobble:[change valueForKey:NSKeyValueChangeNewKey]];
}

@end
