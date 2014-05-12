//
//  User+Utils.m
//  photoquest
//
//  Created by Raymond Kennedy on 7/14/13.
//  Copyright (c) 2013 Randomay Designs. All rights reserved.
//

#import "User+Utils.h"

@implementation User (Utils)

+ (User *)createOrUpdateUser:(PFUser *)currentUser
{
    NSManagedObjectContext *moc = [[DataManager sharedInstance] managedObjectContext];
    
    User *coreDataUser = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameCenterId == %@", [currentUser username]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (![results count] || !results) {
        coreDataUser = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
        coreDataUser.gameCenterAlias = [currentUser valueForKey:@"gameCenterAlias"];
        coreDataUser.gameCenterId = [currentUser username];

    } else if ([results count] == 1){
        coreDataUser = (User *)[results lastObject];
        coreDataUser.gameCenterAlias = [currentUser valueForKey:@"gameCenterAlias"];
    
    } else {
        NSLog(@"[FATAL] - More than one user exists with id: %@", [currentUser username]);
    }
    
    NSError *saveError = nil;
    if (![moc save:&saveError]) NSLog(@"Error saving managedobjectcontext: %@", saveError.localizedDescription);
    
    return coreDataUser;
}

+ (User *)getCurrentUser
{
    NSManagedObjectContext *moc = [[DataManager sharedInstance] managedObjectContext];
    
    User *coreDataUser = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameCenterId == %@", [[PFUser currentUser] username]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:moc]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (![results count] || !results) {
        NSLog(@"[FATAL] - Couldn't find current user in User+Utils/getCurrentUser");
    } else if ([results count] == 1){
        return [results lastObject];
    } else {
        NSLog(@"[FATAL] - More than one user exists with id: %@", [[PFUser currentUser] username]);
    }
    
    return coreDataUser;
}

@end


