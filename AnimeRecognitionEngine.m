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

#import <Growl/GrowlApplicationBridge.h>

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

- (NSString *) sanitize2: (NSString *) string
{
	NSString * _sanitized_name;
	
	_sanitized_name = [string stringByMatching:@"[\\_|\\.|\\-]" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"[:&;]" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\s\\s+" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"^\\s" replace:50 withReferenceString:@""];
	
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
    if (v1 < v2)
        return NSOrderedDescending;
	
	int id1 = [[ob1 objectForKey:@"anime_id"] intValue];
	int id2 = [[ob2 objectForKey:@"anime_id"] intValue];
	
	if (id1 > id2)
		return NSOrderedDescending;
	if (id1 < id2)
		return NSOrderedAscending;
	return NSOrderedSame;
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
		_result = [ordered_animes subarrayWithRange:NSMakeRange(0, 6)];
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
		NSLog(@"Relevant matches (ordered by relevance score):");
	for(int i=0; i<6; i++){
		NSManagedObject * anime = [[_app managedObjectContext] fetchEntityWithName:@"anime" withID:[[[a objectAtIndex:i] valueForKey:@"anime_id"] intValue]];
		NSLog(@"%d: %@, score: %d, id: %d", i+1,[anime valueForKey:@"title"], [[[a objectAtIndex:i] valueForKey:@"score"] intValue],[[anime valueForKey:@"id"] intValue]);
	}
	}@catch (NSException * e) { return; }
}
#endif

-(NSArray *) updateScoreWithNumberBigramsOnResultArray:(NSArray *) array withFileName:(NSString *)string
{
	int highest_score = -1;
	for(NSDictionary *d in array){
		if(highest_score == -1) highest_score = [[d valueForKey:@"score"] intValue];
		if(highest_score == [[d valueForKey:@"score"] intValue]){ // uncertainty state: try to resolve it with 
													   // informations the trigrams didn't capture = bigrams!
			NSManagedObject * anime = [[_app managedObjectContext] fetchEntityWithName:@"anime" withID:[[d valueForKey:@"anime_id"] intValue]];
			NSString * title = [self sanitize2:[anime valueForKey:@"title"]];
			NSString * synonyms = [self sanitize2:[anime valueForKey:@"synonyms"]];
			
			NSString * title_number_match = nil;
			if([title isMatchedByRegex:@"\\s(\\d+)"]) title_number_match = [title stringByMatching:@"\\s(\\d+)" withReferenceFormat:@"$1"];

			NSString * synonyms_number_match = nil;
			if([synonyms isMatchedByRegex:@"\\s(\\d+)"]) synonyms_number_match = [synonyms stringByMatching:@"\\s(\\d+)" withReferenceFormat:@"$1"];
			
			if(title_number_match && [string isMatchedByRegex:[NSString stringWithFormat:@"\\s0{0,1}%@",title_number_match]] || 
			   synonyms_number_match && [string isMatchedByRegex:[NSString stringWithFormat:@"\\s0{0,1}%@",synonyms_number_match]]){
				
				int new_score = [[d valueForKey:@"score"] intValue] + 4;
				[d setValue:[NSNumber numberWithInt:new_score] forKey:@"score"];
			}
		}
	}
	NSArray * ordered_animes = [array sortedArrayUsingFunction:arraySortDesc context:@"score"];
	NSArray * _result;
	@try{
		_result = [ordered_animes subarrayWithRange:NSMakeRange(0, 10)];
	}
	@catch (NSException *e){
		_result = ordered_animes;
	} @finally { }
	return _result;
}

- (BOOL) recognizeEpisodeByTryingNext:(NSArray *)a onName:(NSString *)title{
	NSManagedObject * anime = [[_app managedObjectContext] fetchEntityWithName:@"anime" withID:[[[a objectAtIndex:0] valueForKey:@"anime_id"] intValue]];
	if([[anime valueForKey:@"type"] intValue] != 3){ // not a movie
		int next_episode = [[anime valueForKey:@"my_episodes"] intValue] + 1 <= [[anime valueForKey:@"episodes"] intValue] ? [[anime valueForKey:@"my_episodes"] intValue] + 1 : 1;
		if([title isMatchedByRegex:[NSString stringWithFormat:@"%d", next_episode]]){ // filename contains the episode number
			MALHandler * mal = [MALHandler sharedHandler];
			NSMutableDictionary * values = [NSMutableDictionary new];
			
			if(next_episode < [[anime valueForKey:@"episodes"] intValue]){
				[values setObject:@"1" forKey:@"status"];
			} else {
				[values setObject:@"2" forKey:@"status"];
				[values setObject:@"0" forKey:@"enable_rewatching"];
			}
			
			if([[anime valueForKey:@"my_status"] intValue] == 2)
				[values setObject:@"1" forKey:@"enable_rewatching"];
			
			[values setObject:[NSString stringWithFormat:@"%d", next_episode] forKey:@"episode"];
			[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:(Entry *)anime values:values callback:nil] autorelease]];
			[GrowlApplicationBridge notifyWithTitle:@"Scrobbling file"
										description:[NSString stringWithFormat:@"Scrobbling episode %@ of %@", [values valueForKey:@"episode"], [(Entry*)anime imageTitle]]
								   notificationName:@"Scrobbled file" iconData:nil
										   priority:0 isSticky:NO clickContext:nil];
			return YES;
		}
	} else { // it is a movie scrobble all the episodes in the movie
		MALHandler * mal = [MALHandler sharedHandler];
		NSMutableDictionary * values = [NSMutableDictionary new];
		[values setObject:@"2" forKey:@"status"];
		[values setObject:[[anime valueForKey:@"episodes"] stringValue] forKey:@"episode"];
		[mal.queue addOperation:[[[UpdateOperation alloc] initWithEntry:(Entry *)anime values:values callback:nil] autorelease]];
		[GrowlApplicationBridge notifyWithTitle:@"Scrobbling file"
									description:[NSString stringWithFormat:@"Scrobbling movie: %@", [(Entry*)anime imageTitle]]
							   notificationName:@"Scrobbled file" iconData:nil
									   priority:0 isSticky:NO clickContext:nil];
		return YES;
	}
	
	return NO;
}

// unused function which might be useful in the future
-(NSString *) inferSeriesNameFromFilepath:(NSString *)path
{
	NSString * _f_path = ([path stringByMatching:@"(/.+/).+$" withReferenceFormat:@"$1"]);
	NSString * _f_name = ([path stringByMatching:@"/.+/(.+$)" withReferenceFormat:@"$1"]);
	
	NSArray * ls = [[NSFileManager defaultManager] directoryContentsAtPath:_f_path];
	
	int min=9000;
	for (NSString * _c_f_name in ls) {
		if(![_c_f_name isEqualToString:_f_name] && [_c_f_name isMatchedByRegex:@"(.mkv$|.avi$)"] && ![_c_f_name isMatchedByRegex:@"(Teaser|OP|ED|Opening|Ending)"]){
			NSString * _s_f_name = [self sanitize:_f_name];
			NSString * _s_c_f_name = [self sanitize:_c_f_name];
			
			int l = 0;
			for(int i = 0; i < [_s_f_name length] && i < [_s_c_f_name length]; i++){
				NSRange r = NSMakeRange(0, i);
				if([[_s_f_name substringWithRange:r] isEqualToString: [_s_c_f_name substringWithRange:r]]) l = i;
				else break;
			}
			
			if(l < min) min=l;
		}	
	}
	NSString * result = [[self sanitize:_f_name] substringWithRange:NSMakeRange(0, min)];
	result = [result stringByMatching:@"Ep$" replace:1 withReferenceString:@""];
	result = [result stringByMatching:@"\\s+$" replace:1 withReferenceString:@""];	
	return result;
}

- (void) scrobble: (NSString *)path
{
	if(path!=NULL && path!=nil && ![path isEqual:[NSNull null]]){
		NSString * _f_name = ([path stringByMatching:@"/.+/(.+$)" withReferenceFormat:@"$1"]);
#ifdef DEBUG
		NSLog(@"Detected file to recognize: %@", [self sanitize:_f_name]);
#endif
		NSArray * animes = [self updateScoreWithNumberBigramsOnResultArray:[self recognizetg:[self sanitize:_f_name]] 
															  withFileName:[self sanitize:_f_name]];
#ifdef DEBUG
		[self printRecognitionStats:animes];
#endif
		BOOL r = [self recognizeEpisodeByTryingNext:animes onName:[self sanitize:_f_name]];
		if(!r) [GrowlApplicationBridge notifyWithTitle:@"Failed file recognition"
											 description:@"Check system console and report bug to pigoz."
										notificationName:@"Scrobbled file" iconData:nil
												priority:0 isSticky:NO clickContext:nil];
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if( ![[change valueForKey:NSKeyValueChangeOldKey] isEqual:[change valueForKey:NSKeyValueChangeNewKey]])
		[self scrobble:[change valueForKey:NSKeyValueChangeNewKey]];
}

@end
