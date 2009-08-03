//
//  iMAL_AppDelegate.h
//  iMAL
//
//  Created by Stefano Pigozzi on 7/24/09.
//  Copyright Stefano Pigozzi 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iMAL_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
