//
//  MenuScene.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/5/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "MenuScene.h"
#import "SKLabelButton.h"
#import "GameScene.h"

@interface MenuScene () <SKLabelButtonDelegate>

@property (nonatomic, strong) SKLabelNode *titleLabel;

// Menu Items
@property (nonatomic, strong) SKLabelButton *playButton;
@property (nonatomic, strong) SKLabelButton *highScoresButton;
@property (nonatomic, strong) SKLabelButton *helpButton;

@end

@implementation MenuScene


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
    
    self.titleLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    self.titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 100);
    [self.titleLabel setText:@"Gas Guzzler"];
    [self.titleLabel setFontColor:[SKColor blackColor]];
    [self.titleLabel setFontSize:50.0f];
    
    [self addChild:self.titleLabel];
}

/*
 * Set's up the menu items
 */
- (void)setupMenuItems
{
    self.playButton = [SKLabelButton buttonWithDownColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.86 alpha:1]];
    [self.playButton setDelegate:self];
    [self.playButton setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    [self.playButton setText:@"Play"];
    [self.playButton setFontName:@"AmericanCaptain"];
    [self.playButton setName:@"play"];
    [self.playButton setFontColor:[UIColor darkGrayColor]];
    [self.playButton setFontSize:30.0f];
    [self.playButton setUserInteractionEnabled:YES];
    [self addChild:self.playButton];
    
    self.highScoresButton = [SKLabelButton buttonWithDownColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.86 alpha:1]];
    [self.highScoresButton setDelegate:self];
    [self.highScoresButton setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 50)];
    [self.highScoresButton setText:@"High Scores"];
    [self.highScoresButton setFontName:@"AmericanCaptain"];
    [self.highScoresButton setName:@"highScores"];
    [self.highScoresButton setFontColor:[UIColor darkGrayColor]];
    [self.highScoresButton setFontSize:30.0f];
    [self.highScoresButton setUserInteractionEnabled:YES];
    [self addChild:self.highScoresButton];
    
    self.helpButton = [SKLabelButton buttonWithDownColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.86 alpha:1]];
    [self.helpButton setDelegate:self];
    [self.helpButton setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100)];
    [self.helpButton setText:@"Help"];
    [self.helpButton setFontName:@"AmericanCaptain"];
    [self.helpButton setName:@"help"];
    [self.helpButton setFontColor:[UIColor darkGrayColor]];
    [self.helpButton setFontSize:30.0f];
    [self.helpButton setUserInteractionEnabled:YES];
    [self addChild:self.helpButton];
    
}

/*
 * For the SKLabelButtonDelegate
 */
- (void)buttonHit:(SKLabelButton *)button
{
    if ([button.name isEqualToString:@"play"]) {
        NSLog(@"Play Button Hit");
        
        // Present the game scene
        GameScene *gs = [[GameScene alloc] initWithSize:self.frame.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.3f];
        [self.view presentScene:gs transition:transition];
        
    } else if ([button.name isEqualToString:@"highScores"]) {
        NSLog(@"High Scores Button Hit");
    } else if ([button.name isEqualToString:@"help"]) {
        NSLog(@"Help Button Hit");
    }
}

/*
 * Get the touches
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Test");
}

@end
