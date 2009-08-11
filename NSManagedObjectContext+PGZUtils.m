//
//  NSManagedObjectContext+PGZUtils.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "NSManagedObjectContext+PGZUtils.h"


@implementation NSManagedObjectContext (PGZUtils)

- (NSManagedObject *) fetchOrCreateEntityWithName:(NSString *)entityName withID:(int)value
{
	NSSet *a = [self fetchObjectsForEntityName:entityName
								 withPredicate: [NSPredicate predicateWithFormat:@"id == %d", value]];
	
	if(a!=nil && [a count] == 0){		
		NSManagedObject* new = [NSEntityDescription
									  insertNewObjectForEntityForName:entityName
									  inManagedObjectContext:self];
		[new setValue:[NSNumber numberWithInt:value] forKey:@"id"];
		return new;
	} else {
		//NSLog(@"fetched: %@", [[[a allObjects] objectAtIndex:0] valueForKey:@"title"]);
		return [[a allObjects] objectAtIndex:0];
	}
	return nil;
}

- (NSManagedObject *) fetchEntityWithName:(NSString *)entityName withID:(int)value
{
	NSSet *a = [self fetchObjectsForEntityName:entityName
								 withPredicate: [NSPredicate predicateWithFormat:@"id == %d", value]];
	if(a!=nil && [a count]>0)
		return [[a allObjects] objectAtIndex:0];
	else
		return nil;
}

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate className]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return [NSSet setWithArray:results];
}

@end
