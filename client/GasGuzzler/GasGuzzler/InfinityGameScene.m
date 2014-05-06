//
//  InfinityGameScene.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/5/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "InfinityGameScene.h"
#import "SKSpriteButton.h"
#import "NSDate+Utils.h"
#import "MenuScene.h"

@interface InfinityGameScene () <SKSpriteButtonDelegate>

@property (nonatomic, strong) SKLabelNode *gameTimeLabel;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, strong) SKLabelNode *countDownLabel;
@property (nonatomic, strong) NSTimer *countDownTimer;

@property (nonatomic) NSInteger secondsElapsed;

@property (nonatomic, strong) SKSpriteButton *tapButton;
@property (nonatomic, strong) SKSpriteButton *backButton;


// Value in milliseconds
@property (nonatomic) NSInteger timeThreshold;

@end

@implementation InfinityGameScene

static const NSInteger timerFontSize = 75;

/*
 * Initialize the scene
 */
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Set the background color to white
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // Setup the timer label and count down label and the button
        [self setupGameTimeLabel];
        [self setupCountDownLabel];
        [self setupTapButton];
        [self setupBackButton];
        
        // Set the time buffer to 100 milliseconds for now
        self.timeThreshold = 100;
        
        // Start the countdown
        [self performSelector:@selector(startCountDown) withObject:nil afterDelay:1.0f];
        
    }
    
    return self;
}

/*
 * Setup the timer label
 */
- (void)setupGameTimeLabel
{
    self.gameTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    self.gameTimeLabel.text = @"00.00.00";
    self.gameTimeLabel.fontSize = timerFontSize;
    self.gameTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 115, CGRectGetMidY(self.frame) + 50);
    [self.gameTimeLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [self.gameTimeLabel setFontColor:[UIColor lightGrayColor]];
    [self addChild:self.gameTimeLabel];
}

/*
 * Setup the countdownLabel
 */
- (void)setupCountDownLabel
{
    self.countDownLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    self.countDownLabel.text = @"5";
    self.countDownLabel.fontSize = 100;
    self.countDownLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 10, CGRectGetMidY(self.frame) - 15);
    [self.countDownLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [self.countDownLabel setFontColor:[UIColor blackColor]];
    [self addChild:self.countDownLabel];
}

/*
 * Setup the tap button
 */
- (void)setupTapButton
{
    self.tapButton = [SKSpriteButton spriteButtonWithUpImage:@"tapButton" downImage:@"tapButtonPressed" disabledImage:@"tapButtonDisabled" buttonMode:kTouchDownInside];
    [self.tapButton setDelegate:self];
    [self.tapButton setEnabled:NO];
    [self.tapButton setPosition:CGPointMake(CGRectGetMidX(self.frame), 170)];
    [self.tapButton setName:@"tapButton"];
    
    [self addChild:self.tapButton];
}

/*
 * Add the back button
 */
- (void)setupBackButton
{
    self.backButton = [SKSpriteButton spriteButtonWithUpImage:@"backButton" downImage:@"backButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.backButton setDelegate:self];
    [self.backButton setPosition:CGPointMake(self.tapButton.frame.size.width + 50, self.frame.size.height - (self.tapButton.frame.size.height/2) - 60) ];
    [self.backButton setEnabled:YES];
    [self.backButton setName:@"backButton"];
    
    [self addChild:self.backButton];
}


/*
 * Start the countdown to begin
 */
- (void)startCountDown
{
    self.countDownTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateCountDownTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSDefaultRunLoopMode];
    [self.countDownTimer fire];
}

/*
 * Updates the countDownTimer
 */
- (void)updateCountDownTimer:(NSTimer *)timer
{
    NSInteger countDownValue = [self.countDownLabel.text integerValue];
    countDownValue--;
    
    // If we've reached the end of the count down -- begin the game
    if (countDownValue == 0) {
        
        // Enabled the tap button
        [self.tapButton setEnabled:YES];
        
        // Get rid of the countdown timer, and stop firing the timer
        [self.countDownTimer invalidate];
        [self.countDownLabel removeFromParent];
        
        // Make the gameTime black
        [self.gameTimeLabel setFontColor:[UIColor blackColor]];
        
        [self startGame];
    } else {
        [self.countDownLabel setText:[NSString stringWithFormat:@"%d", (int)countDownValue]];
    }
}

/*
 * Start the game
 */
- (void)startGame
{
    self.startTime = [NSDate date];
    self.secondsElapsed = -1;
    
    self.gameTimer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateGameTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.gameTimer forMode:NSDefaultRunLoopMode];
    [self.gameTimer fire];
}

/*
 * Updates the timer displayed on the screen
 */
- (void)updateGameTimer:(NSTimer *)timer {
    
    // Get the current time on the timer
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeInterval = [currentTime timeIntervalSinceDate:self.startTime];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Get the milliseconds and the timer string
    NSString *timeString = [timerDate getTimerString];
    [self.gameTimeLabel setText:timeString];
    
    // Set the elapsed seconds
    if (self.secondsElapsed != (int)timeInterval) {
        self.secondsElapsed = (int)timeInterval;
    }
}

/*
 * Delegate for skspritebutton when the tap button is hit
 */
- (void)buttonHit:(SKSpriteButton *)button
{
    if ([button.name isEqualToString:@"tapButton"]) {
        [self registerTapButtonHit];
    } else if ([button.name isEqualToString:@"backButton"]) {
        
        MenuScene *ms = [[MenuScene alloc] initWithSize:self.frame.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.3f];
        [self.view presentScene:ms transition:transition];
        
    }
}

/*
 * Register Tap Button hit
 */
- (void)registerTapButtonHit
{
    // Find out how far user is from current second
    NSDate *timeOfTap = [NSDate date];
    NSTimeInterval timeInterval = [timeOfTap timeIntervalSinceDate:self.startTime];
    NSDate *timeSinceStart = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSInteger currentMilliseconds = [timeSinceStart getMillisecondsForCurrentSecond];
    
    // Find the hit color for the floaty text
    UIColor *hitColor;
    hitColor = [UIColor colorWithRed:0.91 green:0.3 blue:0.24 alpha:1];
    
    // From 900--0 or 0-100
    if (self.secondsElapsed == 0 && (currentMilliseconds >= 1000 - self.timeThreshold)) {
        hitColor = [UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1];
    } else if ((currentMilliseconds >= 1000 - self.timeThreshold) || (currentMilliseconds <= self.timeThreshold)) {
        hitColor = [UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1];
    }
    
    NSString *hitTimeString = [timeSinceStart getTimerString];
    
    // Spawn a sprite of the time
    SKLabelNode *hitTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    hitTimeLabel.text = hitTimeString;
    hitTimeLabel.fontSize = timerFontSize;
    hitTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 115, CGRectGetMidY(self.frame) + 50);
    [hitTimeLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [hitTimeLabel setFontColor:hitColor];
    [hitTimeLabel setZPosition:-1];
    [self addChild:hitTimeLabel];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1.3f];
    SKAction *moveUp = [SKAction moveByX:0.0f y:150.0f duration:1.3f];
    SKAction *tween = [SKAction group:[NSArray arrayWithObjects:fadeOut, moveUp, nil]];
    [hitTimeLabel runAction:tween completion:^{
        [hitTimeLabel removeFromParent];
    }];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //    for (UITouch *touch in touches) {
    //        CGPoint location = [touch locationInNode:self];
    //
    //        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    //
    //        sprite.position = location;
    //
    //        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    //
    //        [sprite runAction:[SKAction repeatActionForever:action]];
    //
    //        [self addChild:sprite];
    //    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
}

@end

