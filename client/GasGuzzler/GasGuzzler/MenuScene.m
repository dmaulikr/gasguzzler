//
//  MenuScene.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/5/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "MenuScene.h"
#import "SKLabelButton.h"
#import "SKSpriteButton.h"
#import "InfinityGameScene.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>
#import <Parse/Parse.h>

@interface MenuScene () <SKLabelButtonDelegate, SKSpriteButtonDelegate, GKGameCenterControllerDelegate>

@property (nonatomic, strong) SKSpriteButton *logoButton;

// Menu Items
@property (nonatomic, strong) SKSpriteButton *infinityModeButton;
@property (nonatomic, strong) SKSpriteButton *thirtySecondModeButton;
@property (nonatomic, strong) SKSpriteButton *leaderboardsButton;
@property (nonatomic, strong) SKSpriteButton *helpButton;

@end

@implementation MenuScene

static const NSInteger MENU_ITEMS_HEIGHT = 180;

/*
 * Setup elements of the scene
 */
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // Set the background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

        // Setup the title
        [self setupTitle];
        
        // Setup the menu items
        [self setupMenuItems];
        
        [self setUserInteractionEnabled:YES];
    }
    
    return self;
}

/*
 * Sets up the head title
 */
- (void)setupTitle {
    
    self.logoButton = [SKSpriteButton spriteButtonWithUpImage:@"logo" downImage:@"logoPressed" disabledImage:nil buttonMode:kTouchUpInside];
    self.logoButton.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 130);
    [self.logoButton setEnabled:YES];
    [self.logoButton setDelegate:self];
    [self addChild:self.logoButton];
}

/*
 * Set's up the menu items
 */
- (void)setupMenuItems
{
    float yCenter = MENU_ITEMS_HEIGHT;
    float xCenter = CGRectGetMidX(self.frame);
    
    self.infinityModeButton = [SKSpriteButton spriteButtonWithUpImage:@"infinityModeButton" downImage:@"infinityModeButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.infinityModeButton setDelegate:self];
    [self.infinityModeButton setPosition:CGPointMake(xCenter - 78, yCenter + 78)];
    [self.infinityModeButton setEnabled:YES];
    [self.infinityModeButton setName:@"infinityModeButton"];
    [self addChild:self.infinityModeButton];

    self.thirtySecondModeButton = [SKSpriteButton spriteButtonWithUpImage:@"30secondModeButton" downImage:@"30secondModeButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.thirtySecondModeButton setDelegate:self];
    [self.thirtySecondModeButton setPosition:CGPointMake(xCenter + 78, yCenter + 78)];
    [self.thirtySecondModeButton setEnabled:YES];
    [self.thirtySecondModeButton setName:@"30secondModeButton"];
    [self addChild:self.thirtySecondModeButton];
    
    self.leaderboardsButton = [SKSpriteButton spriteButtonWithUpImage:@"leaderboardsButton" downImage:@"leaderboardsButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.leaderboardsButton setDelegate:self];
    [self.leaderboardsButton setPosition:CGPointMake(xCenter - 78, yCenter - 78)];
    [self.leaderboardsButton setEnabled:YES];
    [self.leaderboardsButton setName:@"leaderboardsButton"];
    [self addChild:self.leaderboardsButton];
    
    self.helpButton = [SKSpriteButton spriteButtonWithUpImage:@"helpButton" downImage:@"helpButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.helpButton setDelegate:self];
    [self.helpButton setPosition:CGPointMake(xCenter + 78, yCenter - 78)];
    [self.helpButton setEnabled:YES];
    [self.helpButton setName:@"helpButton"];
    [self addChild:self.helpButton];
    
}

/*
 * Called from the SKSpriteButton delegate
 */
- (void)buttonHit:(SKSpriteButton *)button
{
    if ([button.name isEqualToString:@"infinityModeButton"]) {
        // Present the game scene
        InfinityGameScene *igs = [[InfinityGameScene alloc] initWithSize:self.frame.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.3f];
        [self.view presentScene:igs transition:transition];
    } else if ([button.name isEqualToString:@"leaderboardsButton"]) {
        //Show the game center
        GKGameCenterViewController *gcvc = [[GKGameCenterViewController alloc] init];
        if (gcvc != nil)
        {
            gcvc.gameCenterDelegate = self;
            gcvc.viewState = GKGameCenterViewControllerStateDefault;
            
            gcvc.leaderboardIdentifier = @"timeLeaderboard";

            [self.view.window.rootViewController presentViewController:gcvc animated: YES completion:nil];
        }
    }
}

/*
 * Called from the delegate
 */
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


/*
 * For the SKLabelButtonDelegate
 */
- (void)labelButtonHit:(SKLabelButton *)button
{
    // Do something.
}

/*
 * Get the touches
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
