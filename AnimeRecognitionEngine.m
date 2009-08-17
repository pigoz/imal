//
//  AnimeRecognitionEngine.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AnimeRecognitionEngine.h"
#import "Entry.h";
#import "NSManagedObjectContext+PGZUtils.h"
#import "MALHandler.h"
#import "UpdateOperation.h"

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
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	return array;
}

// sort the anime array first using descending score, if score is equal sort by 
// ascending anime id (this way first seasons will be first when their
// title is a substring of the second season)
NSInteger arraySortDesc(id ob1, id ob2, void *keyForSorting)
{
    int v1 = [[ob1 objectForKey:@"score"] intValue];
    int v2 = [[ob2 objectForKey:@"score"] intValue];
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else {
		int id1 = [[ob1 objectForKey:@"anime_id"] intValue];
		int id2 = [[ob2 objectForKey:@"anime_id"] intValue];
		if (id1 > id2)
			return NSOrderedDescending;
		else if (v1 < v2)
			return NSOrderedAscending;
        else return NSOrderedSame;
	}
}

- (NSArray *) recognizetg: (NSString *)name
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
	NSArray * animes_tgs = [self allAnimeWithTrigrams:tgs];
	for(NSManagedObject * o in animes_tgs){ // single anime tag
		BOOL found = NO;
		NSMutableDictionary * cur;
		for(NSMutableDictionary * temp in animes){
			cur = temp;
			if([[temp valueForKey:@"anime_id"] isEqual:[[o valueForKey:@"anime"] valueForKey:@"id"]]){
				found = YES; break;
			}
		}
		
		if(found){
			int score = [[o valueForKey:@"score"] intValue] + [[cur valueForKey:@"score"] intValue];
			[cur setValue:[NSNumber numberWithInt:score] forKey:@"score"];
		} else {
			Entry * anime = [[o valueForKey:@"anime"] valueForKey:@"id"];
			NSNumber * score = [o valueForKey:@"score"];
			[animes addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:anime,score,nil]
																 forKeys:[NSArray arrayWithObjects:@"anime_id",@"score",nil]]];
		}
	}
	
	NSArray * ordered_animes = [animes sortedArrayUsingFunction:arraySortDesc context:@"score"];
	NSArray * _result;
	@try{
		_result = [ordered_animes subarrayWithRange:NSMakeRange(0, 5)];
	}
	@catch (NSException *e){
		_result = ordered_animes;
	} @finally { }
	return _result;
}

#ifdef DEBUG
-(void)printRecognitionStats:(NSArray *)a
{
	@try{
	for(int i=0; i<3; i++){
		NSManagedObject * anime = [[_app managedObjectContext] fetchEntityWithName:@"anime" withID:[[[a objectAtIndex:i] valueForKey:@"anime_id"] intValue]];
		NSLog(@"%d: %@, score: %d", i+1,[anime valueForKey:@"title"], [[[a objectAtIndex:i] valueForKey:@"score"] intValue]);
	}
	}@catch (NSException * e) { return; }
}
#endif

- (BOOL) recognizeEpisodeByTryingNext:(NSArray *)a onName:(NSString *)title{
	@try{
		for(int i=0; i<3; i++){
			NSManagedObject * anime = [[_app managedObjectContext] fetchEntityWithName:@"anime" withID:[[[a objectAtIndex:i] valueForKey:@"anime_id"] intValue]];
			if([[anime valueForKey:@"type"] intValue] != 3){ // not a movie
				int next_episode = [[anime valueForKey:@"my_episodes"] intValue] + 1;
				if([title isMatchedByRegex:[NSString stringWithFormat:@"%d", next_episode]]){ // filename contains the episode number
					MALHandler * mal = [MALHandler sharedHandler];
					NSMutableDictionary * values = [NSMutableDictionary new];
					[values setObject:@"1" forKey:@"status"];
					[values setObject:[NSString stringWithFormat:@"%d", next_episode] forKey:@"episode"];
					[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:(Entry *)anime values:values callback:nil] autorelease]];
					return YES;
				}
			}
		}
	}@catch (NSException * e) { return NO; }
	return NO;
}

- (void) scrobble: (NSString *)path
{
	if(path!=NULL && path!=nil && ![path isEqual:[NSNull null]]){
		NSString * _f_name = ([path stringByMatching:@"/.+/(.+$)" withReferenceFormat:@"$1"]);
		NSLog(@"Detected file to recognize: %@", [self sanitize:_f_name]);
		NSArray * animes = [self recognizetg:[self sanitize:_f_name]];
#ifdef DEBUG
		[self printRecognitionStats:animes];
#endif
		[self recognizeEpisodeByTryingNext:animes onName:_f_name];
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if( ![[change valueForKey:NSKeyValueChangeOldKey] isEqual:[change valueForKey:NSKeyValueChangeNewKey]])
		[self scrobble:[change valueForKey:NSKeyValueChangeNewKey]];
}

@end
