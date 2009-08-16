//
//  IndexOperation.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/16/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "IndexOperation.h"
#import "PGZCallback.h"
#import "NSManagedObjectContext+PGZUtils.h"
#import "Entry.h";


@implementation IndexOperation

@synthesize __db;
@synthesize __done;

-(IndexOperation *)initWithContext:(NSManagedObjectContext *)ctx callback:(PGZCallback *) cb
{
	self = [super init];
	if (self != nil) {
		self.__db = ctx;
		self.__done = cb;
	}
	return self;
}

// helper method to get all animes
- (NSArray *) allAnime
{
	NSManagedObjectContext *moc = self.__db;
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"anime" inManagedObjectContext:moc];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:nil];
	
	[request setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	return array;
}

- (NSString *) sanitize: (NSString *) string
{
	NSString * _sanitized_name;
	
	_sanitized_name = [string stringByMatching:@"[\\_|\\-|\\.]" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"^\\s" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"[:&\\!]" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\s\\s+" replace:50 withReferenceString:@" "];
	
	return _sanitized_name;
}

// inserts if not exists.
- (void) insertTrigram:(NSString *)tg anime:(NSManagedObject *)anime
{
	NSSet *a = [self.__db fetchObjectsForEntityName:@"trigram"
								 withPredicate: [NSPredicate predicateWithFormat:@"(tg == %@) && (anime == %@)", tg, anime]];
	
	if(a!=nil && [a count] == 0){		
		NSManagedObject* new = [NSEntityDescription
								insertNewObjectForEntityForName:@"trigram"
								inManagedObjectContext:self.__db];
		[new setValue:tg forKey:@"tg"];
		[new setValue:anime forKey:@"anime"];
		NSLog(@"Inserted trigram:%@", tg);
	} else {
		NSLog(@"Old Trigram:%@", tg);
	}
}

-(void)main
{
	NSArray * animes = [self allAnime];
	for(Entry * e in animes){
		NSLog(@"Indexing:%@", [self sanitize: [e imageTitle]]);
		NSArray * title_words = [[self sanitize: [e imageTitle]] componentsSeparatedByString:@" "];
		for(NSString * word in title_words){
			word = [@" " stringByAppendingString:word]; // this way the first trigram will notice it is a word start
			if([word length]>=3)
				for(int idx = 0; idx <= [word length]-3; idx++){
					NSString * tg = [word substringWithRange:NSMakeRange(idx, 3)]; //trigram
					[self insertTrigram:tg anime:e];
				}
		}
	}
	
	[__done perform];
}

@end
