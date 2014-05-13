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
#import "InfinityScoreNode.h"
#import "SKEase.h"
#import "UIColor+Extensions.h"
#import <AudioToolbox/AudioToolbox.h>
#import <GameKit/GameKit.h>

@interface InfinityGameScene () <SKSpriteButtonDelegate>

@property (nonatomic, strong) SKLabelNode *gameTimeLabel;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic) CFAbsoluteTime startTime;

@property (nonatomic) NSInteger secondsElapsed;
@property (nonatomic) NSInteger lastSecondHit;
@property (nonatomic) NSInteger perfectHits;
@property (nonatomic) BOOL isOpenForHit;
@property (nonatomic) BOOL hasHitForSecond;

@property (nonatomic, strong) SKSpriteButton *tapButton;
@property (nonatomic, strong) SKSpriteButton *beginButton;
@property (nonatomic, strong) SKSpriteButton *restartButton;
@property (nonatomic, strong) SKSpriteButton *backButton;

@property (nonatomic, strong) InfinityScoreNode *scoreNode;

// Value in milliseconds
@property (nonatomic) NSInteger timeThreshold;

@end

@implementation InfinityGameScene

typedef enum gameEndings {
    kSkippedSecond,
    kMissedHit
} GameEnder;

static const NSInteger TIME_THRESHOLD = 100;

static const NSInteger TIMER_FONT_SIZE = 75;
static const NSInteger MILLISECONDS_IN_SECOND = 1000;
static const NSInteger SECONDS_IN_MINUTE = 60;
static const NSInteger TAP_BUTTON_HEIGHT = 25;
static const NSInteger BUTTON_Z_LEVEL = 10;

/*
 * Initialize the scene
 */
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Set the background color to white
        self.backgroundColor = [UIColor whiteColor];
        
        // Setup the timer label and count down label and the button
        [self setupGameTimeLabel];
        [self setupTapButton];
        [self setupBeginButton];
        [self setupRestartButton];
        [self setupBackButton];
        
        // Hide the tap button @ start
        [self.tapButton setHidden:YES];
        [self.beginButton setHidden:NO];
        [self.restartButton setHidden:YES];
        
        // Setup the score node
        [self setupScoreNode];
        
        [self swapZs:self.restartButton withSprite:self.beginButton];
        
        // Set the time buffer to 100 milliseconds for now
        self.timeThreshold = TIME_THRESHOLD;
        
    }
    
    return self;
}

/*
 * Swaps the z-index of the tap button and begin button
 */
- (void)swapZs:(SKSpriteNode *)sprite1 withSprite:(SKSpriteNode *)sprite2
{
    int zIndex2 = sprite2.zPosition;
    sprite2.zPosition = sprite1.zPosition;
    sprite1.zPosition = zIndex2;
}

/*
 * Setup the timer label
 */
- (void)setupGameTimeLabel
{
    self.gameTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    self.gameTimeLabel.text = @"00.00.00";
    self.gameTimeLabel.fontSize = TIMER_FONT_SIZE;
    CGSize textSize = [[self.gameTimeLabel text] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanCaptain" size:TIMER_FONT_SIZE]}];
    CGFloat strikeWidth = textSize.width;
    self.gameTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame) - strikeWidth/2, CGRectGetMidY(self.frame));
    [self.gameTimeLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [self.gameTimeLabel setFontColor:[UIColor blackColor]];
    [self.gameTimeLabel setZPosition:BUTTON_Z_LEVEL - 1];
    
    [self addChild:self.gameTimeLabel];
}

/*
 * Sets up the score node
 */
- (void)setupScoreNode
{
    self.scoreNode = [InfinityScoreNode scoreNodeWithScore:0 perfects:0];
    
    [self.scoreNode setPosition:CGPointMake(CGRectGetMidX(self.frame) - 320, CGRectGetMidY(self.frame))];
    [self addChild:self.scoreNode];
    
}

/*
 * Setup the tap button
 */
- (void)setupTapButton
{
    self.tapButton = [SKSpriteButton spriteButtonWithUpImage:@"tapButton" downImage:@"tapButtonPressed" disabledImage:nil buttonMode:kTouchDownInside];
    [self.tapButton setDelegate:self];
    NSInteger buttonHeight = [self.tapButton getHeight];
    [self.tapButton setPosition:CGPointMake(CGRectGetMidX(self.frame), TAP_BUTTON_HEIGHT + (buttonHeight/2))];
    [self.tapButton setEnabled:YES];
    [self.tapButton setName:@"tapButton"];
    [self.tapButton setZPosition:BUTTON_Z_LEVEL];
    [self addChild:self.tapButton];
}

/*
 * Sets up the begin button / (tap button)
 */
- (void)setupBeginButton
{
    self.beginButton = [SKSpriteButton spriteButtonWithUpImage:@"beginButton" downImage:@"beginButtonPressed" disabledImage:nil buttonMode:kTouchDownInside];
    [self.beginButton setDelegate:self];
    NSInteger buttonHeight = [self.beginButton getHeight];
    [self.beginButton setPosition:CGPointMake(CGRectGetMidX(self.frame), TAP_BUTTON_HEIGHT + (buttonHeight/2))];
    [self.beginButton setEnabled:YES];
    [self.beginButton setName:@"beginButton"];
    [self.beginButton setZPosition:BUTTON_Z_LEVEL + 1];
    [self addChild:self.beginButton];
}

/*
 * Sets up the restart button / (tap button)
 */
- (void)setupRestartButton
{
    self.restartButton = [SKSpriteButton spriteButtonWithUpImage:@"restartButton" downImage:@"restartButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.restartButton setDelegate:self];
    NSInteger buttonHeight = [self.restartButton getHeight];
    [self.restartButton setPosition:CGPointMake(CGRectGetMidX(self.frame), TAP_BUTTON_HEIGHT + (buttonHeight/2))];
    [self.restartButton setEnabled:YES];
    [self.restartButton setName:@"restartButton"];
    [self.restartButton setZPosition:BUTTON_Z_LEVEL + 2];
    [self addChild:self.restartButton];
}

/*
 * Add the back button
 */
- (void)setupBackButton
{
    self.backButton = [SKSpriteButton spriteButtonWithUpImage:@"backButton" downImage:@"backButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.backButton setDelegate:self];
    [self.backButton setPosition:CGPointMake(self.backButton.frame.size.width/2 + 10, self.frame.size.height - (self.backButton.frame.size.height/2) - 27) ];
    [self.backButton setEnabled:YES];
    [self.backButton setName:@"backButton"];
    [self.backButton setZPosition:BUTTON_Z_LEVEL];
    
    [self addChild:self.backButton];
}

/*
 * Start the game
 */
- (void)startGame
{
    self.secondsElapsed = 0;
    self.lastSecondHit = 0;
    self.perfectHits = 0;
    self.isOpenForHit = NO;
    self.hasHitForSecond = NO;
    
    // change the font color
    [self.gameTimeLabel setFontColor:[UIColor blackColor]];
    
    // Unhide the tap button
    [self.tapButton setHidden:NO];
    [self.beginButton setHidden:YES];
    [self swapZs:self.tapButton withSprite:self.beginButton];
    
    // Set the start time
    self.startTime = CFAbsoluteTimeGetCurrent();
    
    self.gameTimer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateGameTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.gameTimer forMode:NSDefaultRunLoopMode];
    [self.gameTimer fire];
}

/*
 * Updates the timer displayed on the screen
 */
- (void)updateGameTimer:(NSTimer *)timer {
    
    // Get the current time on the timer
    CFTimeInterval timeInterval = CFAbsoluteTimeGetCurrent() - self.startTime;
    
    int currentMinutes = timeInterval / 60;
    int currentSeconds = (int)floor(timeInterval) % 60;
    int currentMilliseconds = (int)(timeInterval * 1000) % 1000;
    double tenths = (double)currentMilliseconds/10;
    int roundedMilliseconds = round(tenths) * 10;
    
    [self.gameTimeLabel setText:[NSString stringWithFormat:@"%02d.%02d.%02d", currentMinutes, currentSeconds, roundedMilliseconds/10]];
    
    // Set the elapsed seconds
    if (self.secondsElapsed != (int)timeInterval) {
        self.secondsElapsed = (int)timeInterval;
    }
    
    if (!((roundedMilliseconds >= MILLISECONDS_IN_SECOND - self.timeThreshold) || (roundedMilliseconds <= self.timeThreshold))) {
        if (self.secondsElapsed - 1 >= self.lastSecondHit) {
            [self triggerGameEndFrom:kSkippedSecond];
        }
    }
}

/*
 * Trigger game end
 */
- (void)triggerGameEndFrom:(GameEnder)reason
{
    NSLog(@"GAME OVER");
    
    [self.gameTimer invalidate];
    [self.gameTimeLabel setFontColor:[UIColor gameEndingRed]];
    [self.beginButton setHidden:YES];
    [self.tapButton setHidden:YES];
    
    [self swapZs:self.tapButton withSprite:self.beginButton];
    [self swapZs:self.beginButton withSprite:self.restartButton];
    
    int64_t calculatedScore = self.lastSecondHit;

    // Send the score to GameCenter
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        
        
        if (calculatedScore > 0) [self reportScore:calculatedScore forLeaderboardID:@"timeLeaderboard"];
        else NSLog(@"Score wasn't high enough to send to GameCenter");
    }
    
    [self.restartButton setEnabled:NO];
    [self.restartButton setHidden:NO];
    [self performSelector:@selector(enableRestart:) withObject:nil afterDelay:1.0f];
    
    NSString *losingTimeString;
    
    if (reason == kSkippedSecond) {
        NSString *oldTime = self.gameTimeLabel.text;
        oldTime = [[oldTime substringToIndex:6] stringByAppendingString:[NSString stringWithFormat:@"%02d", ((int)self.timeThreshold/10) + 1]];
        losingTimeString = oldTime;
    } else {
        losingTimeString = self.gameTimeLabel.text;
    }
    
    [self.scoreNode setScore:self.lastSecondHit perfects:self.perfectHits losingTime:losingTimeString];
    
    // Animate score
    [self animateScoreChange];
    
}

/*
 * Enables the restart button to be hit after 1 second
 */
- (void)enableRestart:(id)sender
{
    [self.restartButton setEnabled:YES];
}

/*
 * Animate the score changing on the screen
 */
- (void)animateScoreChange
{
    SKAction *moveInScoreNode = [SKEase MoveToWithNode:self.scoreNode EaseFunction:CurveTypeCubic Mode:EaseOut Time:0.5f ToVector:CGVectorMake(self.scoreNode.frame.origin.x + 320, self.scoreNode.frame.origin.y)];
    [self.scoreNode runAction:moveInScoreNode completion:^{
        if (self.scoreNode.frame.origin.x > 320) {
            [self.scoreNode setPosition:CGPointMake(CGRectGetMidX(self.frame) - 320, CGRectGetMidY(self.frame))];
        }
    }];
    
    SKAction *moveOutTimeNode = [SKEase MoveToWithNode:self.gameTimeLabel EaseFunction:CurveTypeCubic Mode:EaseOut Time:0.5f ToVector:CGVectorMake(self.gameTimeLabel.frame.origin.x + 320, self.gameTimeLabel.frame.origin.y)];
    [self.gameTimeLabel runAction:moveOutTimeNode completion:^{
        if (self.gameTimeLabel.frame.origin.x > 320) {
            self.gameTimeLabel.text = @"00.00.00";
            self.gameTimeLabel.fontSize = TIMER_FONT_SIZE;
            CGSize textSize = [[self.gameTimeLabel text] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanCaptain" size:TIMER_FONT_SIZE]}];
            CGFloat strikeWidth = textSize.width;
            [self.gameTimeLabel setPosition:CGPointMake(CGRectGetMidX(self.frame) - 320 - (strikeWidth/2), CGRectGetMidY(self.frame))];
        }
    }];
}

/*
 * Report the score to GameCenter
 */
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString *)identifier
{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        //Do something interesting here.
        if(error) {
            NSLog(@"Error: %@", [error localizedFailureReason]);
        } else {
            NSLog(@"Successfully posted score to GameCenter");
        }
        
    }];
}


/*
 * Register Tap Button hit
 */
- (void)registerTapButtonHit
{
    CFTimeInterval timeInterval = CFAbsoluteTimeGetCurrent() - self.startTime;
    
    int currentMinutes = timeInterval / 60;
    int currentSeconds = (int)floor(timeInterval) % 60;
    int totalSeconds = (int)floor(timeInterval);
    int currentMilliseconds = (int)(timeInterval * 1000) % 1000;
    double tenths = (double)currentMilliseconds/10;
    int roundedMilliseconds = round(tenths) * 10;
    
    // Find the hit color for the floaty text
    UIColor *hitColor;
    hitColor = [UIColor gameEndingRed];
    
    // From 900--0 or 0-100
    if ((roundedMilliseconds >= MILLISECONDS_IN_SECOND - self.timeThreshold) || (roundedMilliseconds <= self.timeThreshold)) {
        
        if (roundedMilliseconds == 0 || roundedMilliseconds == 1000) {
            
            if (roundedMilliseconds == 1000) {
                totalSeconds += 1;
                
                if (currentSeconds == SECONDS_IN_MINUTE - 1) currentSeconds = 0;
                else currentSeconds += 1;
            }
            
            self.lastSecondHit = totalSeconds;
            self.perfectHits++;
            
            NSLog(@"Perfect Hit at %d millisecond(s)!", (int)roundedMilliseconds);
            
            // Do the perfect animations
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self flashBackground:[UIColor perfectGreen]];
            
        } else if (roundedMilliseconds >= MILLISECONDS_IN_SECOND - self.timeThreshold) {
            self.lastSecondHit = totalSeconds + 1;
            NSLog(@"Under Hit at %d millisecond(s)!", (int)roundedMilliseconds);
            
        } else {
            self.lastSecondHit = totalSeconds;
            NSLog(@"Over Hit at %d millisecond(s)!", (int)roundedMilliseconds);
            
        }
        
        hitColor = [UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1];
        self.hasHitForSecond = YES;
    } else {
        [self triggerGameEndFrom:kMissedHit];
        return;
    }
    
    if (roundedMilliseconds == 1000) roundedMilliseconds = 0;
    
    
    // Spawn a sprite of the time
    SKLabelNode *hitTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    hitTimeLabel.text = [NSString stringWithFormat:@"%02d.%02d.%02d", currentMinutes, currentSeconds, roundedMilliseconds/10];
    hitTimeLabel.fontSize = TIMER_FONT_SIZE;
    CGSize textSize = [@"00.00.00" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanCaptain" size:TIMER_FONT_SIZE]}];
    CGFloat strikeWidth = textSize.width;
    hitTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame) - strikeWidth/2, CGRectGetMidY(self.frame));
    [hitTimeLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [hitTimeLabel setFontColor:hitColor];
    [hitTimeLabel setZPosition:BUTTON_Z_LEVEL - 2];
    [self addChild:hitTimeLabel];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1.3f];
    SKAction *moveUp = [SKEase MoveToWithNode:hitTimeLabel EaseFunction:CurveTypeCubic Mode:EaseOut Time:1.3f ToVector:CGVectorMake(hitTimeLabel.frame.origin.x, hitTimeLabel.frame.origin.y + 100)];
    SKAction *tween = [SKAction group:[NSArray arrayWithObjects:fadeOut, moveUp, nil]];
    [hitTimeLabel runAction:tween completion:^{
        [hitTimeLabel removeFromParent];
    }];
}

/*
 * Flashes the background a color
 */
- (void)flashBackground:(UIColor *)color
{
    SKSpriteNode *bgFlash = [SKSpriteNode spriteNodeWithColor:color size:self.size];
    [bgFlash setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    [bgFlash setZPosition:1];
    [bgFlash setAlpha:0.0f];
    [self addChild:bgFlash];
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0f duration:.2f];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0f duration:.2f];
    SKAction *sequence = [SKAction sequence:[NSArray arrayWithObjects:fadeIn, fadeOut, nil]];
    [bgFlash runAction:sequence completion:^{
        [bgFlash removeFromParent];
    }];
}

/*
 * Delegate for skspritebutton when the tap button is hit
 */
- (void)buttonHit:(SKSpriteButton *)button
{
    if ([button.name isEqualToString:@"tapButton"]) {
        [self registerTapButtonHit];
    } else if ([button.name isEqualToString:@"backButton"]) {
        [self leaveScene];
    } else if ([button.name isEqualToString:@"beginButton"]) {
        NSLog(@"New Game Started.");
        // start the game
        [self startGame];
    } else if ([button.name isEqualToString:@"restartButton"]) {
        
        // Set the timer back to 00.00.00
        [self.gameTimeLabel setText:@"00.00.00"];
        [self.gameTimeLabel setFontColor:[UIColor blackColor]];
        
        // Move the score out of the way
        [self animateScoreChange];
        
        [self.tapButton setHidden:YES];
        [self.beginButton setHidden:NO];
        [self.restartButton setHidden:YES];
        
        [self swapZs:self.restartButton withSprite:self.beginButton];
        
    }
}

/*
 * Leave scene
 */
- (void)leaveScene
{
    // Invalidate the timers before leavint the scene
    [self.gameTimer invalidate];
    
    // Present the menu scene again
    MenuScene *ms = [[MenuScene alloc] initWithSize:self.frame.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.3f];
    [self.view presentScene:ms transition:transition];
}

@end

