//
//  NSManagedObjectContext+PGZUtils.h
//  iMAL
//
//  Created by Stefano Pigozzi on 8/6/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSManagedObjectContext (PGZUtils)

-(NSManagedObject *)fetchOrCreateForEntityName:(NSString *)entityName withID:(int)value;
-(NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ...;

@end
