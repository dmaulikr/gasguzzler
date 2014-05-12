//
//  AppDelegate.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/4/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import <GameKit/GameKit.h>
#import <Parse/Parse.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Hockey stuff
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"1dbded089e2c4562cb4d166eb57a1b2a"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    [Parse setApplicationId:@"0i9gbZ0Rac7dFKI4yM0imy2K3RzsWcnrNTrKj6fp"
                  clientKey:@"UL3oDdKtafceXoN7IELlZQDZTOp6tspOelTB7uwV"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Authenticate the Game Center player
    [self authenticateLocalPlayer];
    
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
            
            
        } else {
            
            // Disable game center
            
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
