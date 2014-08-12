//
//  AppDelegate.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/4/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "AppDelegate.h"
#import "User+Utils.h"
#import "Appirater.h"
#import <HockeySDK/HockeySDK.h>
#import <GameKit/GameKit.h>
#import <Parse/Parse.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Appirater setAppId:@"877124092"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:15];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:YES];
    
    // Hockey stuff
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1dbded089e2c4562cb4d166eb57a1b2a"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    [Parse setApplicationId:@"0i9gbZ0Rac7dFKI4yM0imy2K3RzsWcnrNTrKj6fp"
                  clientKey:@"UL3oDdKtafceXoN7IELlZQDZTOp6tspOelTB7uwV"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // Authenticate the Game Center player
    [self authenticateLocalPlayer];
    
    [Appirater appLaunched:YES];
    
    // Override point for customization after application launch.
    return YES;
}

/*
 * Called on every app launch, pretty much checks the current state of the Game Center user
 * and acts accordingly.
 */
- (void)authenticateLocalPlayer
{
    // If the player is already authenticated the block returns pretty much immediately so
    // no need to worry about network lag. If the user hasn't authenticated yet, show the controller
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
        
        if (viewController) {
            // Gamecenter wants us to display the controller
            [self.window.rootViewController presentViewController:viewController animated:YES completion:^{}];
            
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            
            PFUser *currentUser = [PFUser currentUser];
            if (!currentUser) {
                // Send the information to parse
                [self updateParse];
            } else {
                NSLog(@"PFUser already logged in.");
                [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [User createOrUpdateUser:(PFUser *)object];
                }];
            }
            
            
        } else {
            
            // Disable game center
            
        }
    }];
}

/*
 * Send GameCenter info to parse
 */
- (void)updateParse
{
    // First try to login the user
    NSString *username = [GKLocalPlayer localPlayer].playerID;
    [PFUser logInWithUsernameInBackground:username password:@"Taps!" block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
            NSLog(@"PFUser has logged in!");
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation setObject:[PFUser currentUser] forKey:@"owner"];
            [currentInstallation saveInBackground];
            
            // Update their alias if it has changed
            if (![[user valueForKey:@"alias"]  isEqualToString:[GKLocalPlayer localPlayer].alias]) {
                [[PFUser currentUser] setValue:[GKLocalPlayer localPlayer].alias forKey:@"gameCenterAlias"];
                [[PFUser currentUser] saveInBackground];
            }
            
            [User createOrUpdateUser:[PFUser currentUser]];
            
            // Post a positive notification name
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ParseInfoLoaded" object:nil];
            
        } else {
            // The login failed. Check error to see why.
            NSLog(@"User probably doesn't have an account yet");
            PFUser *newUser = [PFUser user];
            newUser.username = [GKLocalPlayer localPlayer].playerID;
            newUser.password = @"Taps!";
            
            [newUser setValue:[GKLocalPlayer localPlayer].alias forKey:@"gameCenterAlias"];

            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    // Hooray! Let them use the app now.
                    NSLog(@"PFUser has logged in for the first time!");
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:[PFUser currentUser] forKey:@"owner"];
                    [currentInstallation saveInBackground];
                    
                    [User createOrUpdateUser:[PFUser currentUser]];
                    
                    // Post a positive notification name
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParseInfoLoaded" object:nil];
                } else {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSLog(@"Error creating Parse account: %@", errorString);
                }
            }];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
