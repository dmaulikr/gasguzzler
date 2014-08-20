//
//  ThirtyGameScene.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/10/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "ThirtyGameScene.h"
#import "SKSpriteButton.h"
#import "NSDate+Utils.h"
#import "MenuScene.h"
#import "ThirtyScoreNode.h"
#import "SKEase.h"
#import "UIColor+Extensions.h"
#import "HelpView.h"

#import <AudioToolbox/AudioToolbox.h>
#import <GameKit/GameKit.h>

@interface ThirtyGameScene () <SKSpriteButtonDelegate, HelpViewDelegate>

@property (nonatomic, strong) SKLabelNode *gameTimeLabel;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic) CFAbsoluteTime startTime;

@property (nonatomic) NSInteger secondsElapsed;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger missHits;
@property (nonatomic) NSInteger perfectHits;

@property (nonatomic, strong) SKSpriteButton *tapButton;
@property (nonatomic, strong) SKSpriteButton *beginButton;
@property (nonatomic, strong) SKSpriteButton *restartButton;
@property (nonatomic, strong) SKSpriteButton *backButton;

@property (nonatomic, strong) SKNode *gameNode;
@property (nonatomic, strong) ThirtyScoreNode *scoreNode;
@property (nonatomic, strong) HelpView *hv;

// Value in milliseconds
@property (nonatomic) NSInteger timeThreshold;

@end

@implementation ThirtyGameScene

typedef enum gameEndings {
    kSkippedSecond,
    kMissedHit
} GameEnder;

static const NSInteger TIME_THRESHOLD = 100;
static const NSInteger FONT_SIZE = 75;

static const NSInteger MILLISECONDS_IN_SECOND = 1000;
static const NSInteger SECONDS_IN_MINUTE = 60;
static const NSInteger THIRTY_SECONDS = 30;

static const NSInteger BUTTON_Z_LEVEL = 10;

static const NSInteger SCORE_MULTIPLYING_FACTOR = 10;

static const NSInteger TAP_BUTTON_HEIGHT_4_INCH = 68;
static const NSInteger TAP_BUTTON_HEIGHT_3_5_INCH = 20;

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

/*
 * Initialize the scene
 */
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Set the background color to white
        self.backgroundColor = [UIColor whiteColor];
        
        // Setup the game node
        self.gameNode = [[SKNode alloc] init];
        [self addChild:self.gameNode];
        
        // Setup the timer label and count down label and the button
        [self setupGameTimeLabel];
        [self setupScoreLabel];
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

- (void)didMoveToView:(SKView *)view
{
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"thirtyGame"]) {
    
        if (!self.hv) {
            self.hv = [[HelpView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) gameMode:@"thirty"];
            [self.hv setDelegate:self];
        }
        
        [self.hv setAlpha:0.0f];
        [self.view addSubview:self.hv];
        
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.hv setAlpha:1.0f];
        } completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"thirtyGame"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didExitHelpView
{
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.hv setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.hv removeFromSuperview];
    }];
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
    self.gameTimeLabel.fontSize = FONT_SIZE;
    CGSize textSize = [[self.gameTimeLabel text] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AmericanCaptain" size:FONT_SIZE]}];
    CGFloat strikeWidth = textSize.width;
    float yCoord = 0;
    if (isiPhone5) {
        yCoord = CGRectGetMidY(self.frame) + 30;
    } else {
        yCoord = CGRectGetMidY(self.frame);
    }
    self.gameTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame) - strikeWidth/2, yCoord);
    [self.gameTimeLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [self.gameTimeLabel setFontColor:[UIColor blackColor]];
    [self.gameTimeLabel setZPosition:BUTTON_Z_LEVEL - 1];
    
    [self.gameNode addChild:self.gameTimeLabel];
}

/*
 * Set up the score label
 */
- (void)setupScoreLabel
{
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [self.scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    self.scoreLabel.text = @"0";
    self.scoreLabel.fontSize = FONT_SIZE;
    float yCoord = 0;
    if (isiPhone5) {
        yCoord = CGRectGetMidY(self.frame) + 30;
    } else {
        yCoord = CGRectGetMidY(self.frame);
    }
    self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), yCoord + 100);
    [self.scoreLabel setFontColor:[UIColor scoreTurqoise]];
    [self.scoreLabel setZPosition:BUTTON_Z_LEVEL - 1];
    
    [self.gameNode addChild:self.scoreLabel];
}

/*
 * Sets up the score node
 */
- (void)setupScoreNode
{
    self.scoreNode = [ThirtyScoreNode scoreNodeWithScore:0 perfects:0];
    
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
    float yCoord = 0;
    if (isiPhone5) {
        yCoord = TAP_BUTTON_HEIGHT_4_INCH;
    } else {
        yCoord = TAP_BUTTON_HEIGHT_3_5_INCH;
    }
    [self.tapButton setPosition:CGPointMake(CGRectGetMidX(self.frame), yCoord + (buttonHeight/2))];
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
    float yCoord = 0;
    if (isiPhone5) {
        yCoord = TAP_BUTTON_HEIGHT_4_INCH;
    } else {
        yCoord = TAP_BUTTON_HEIGHT_3_5_INCH;
    }
    [self.beginButton setPosition:CGPointMake(CGRectGetMidX(self.frame), yCoord + (buttonHeight/2))];
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
    float yCoord = 0;
    if (isiPhone5) {
        yCoord = TAP_BUTTON_HEIGHT_4_INCH;
    } else {
        yCoord = TAP_BUTTON_HEIGHT_3_5_INCH;
    }
    [self.restartButton setPosition:CGPointMake(CGRectGetMidX(self.frame), yCoord + (buttonHeight/2))];
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
    self.score = 0;
    self.missHits = 0;
    self.perfectHits = 0;
    
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
    
    if (roundedMilliseconds == 1000) roundedMilliseconds = 0;
    
    [self.gameTimeLabel setText:[NSString stringWithFormat:@"%02d.%02d.%02d", currentMinutes, currentSeconds, roundedMilliseconds/10]];
    
    // Set the elapsed seconds
    if (self.secondsElapsed != (int)timeInterval) {
        self.secondsElapsed = (int)timeInterval;
    }
    
    if (!((roundedMilliseconds >= MILLISECONDS_IN_SECOND - self.timeThreshold) || (roundedMilliseconds <= self.timeThreshold))) {
        if (self.secondsElapsed >= THIRTY_SECONDS) {
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
    
    int64_t calculatedScore = self.score;
    
    // Send the score to GameCenter
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        
        if (calculatedScore > 0) [self reportScore:calculatedScore forLeaderboardID:@"thirtySecondLeaderboard"];
        else NSLog(@"Score wasn't high enough to send to GameCenter");
    }
    
    [self.restartButton setEnabled:NO];
    [self.restartButton setHidden:NO];
    [self performSelector:@selector(enableRestart:) withObject:nil afterDelay:0.5f];
    
    NSString *losingTimeString;
    
    if (reason == kSkippedSecond) {
        NSString *oldTime = self.gameTimeLabel.text;
        oldTime = [[oldTime substringToIndex:6] stringByAppendingString:[NSString stringWithFormat:@"%02d", ((int)self.timeThreshold/10) + 1]];
        losingTimeString = oldTime;
    } else {
        losingTimeString = self.gameTimeLabel.text;
    }
    
    [self.scoreNode setScore:self.score perfects:self.perfectHits missedHits:self.missHits];
    
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
    SKAction *moveScoreNode = [SKEase MoveToWithNode:self.scoreNode EaseFunction:CurveTypeCubic Mode:EaseOut Time:0.5f ToVector:CGVectorMake(self.scoreNode.frame.origin.x + self.frame.size.width, self.scoreNode.frame.origin.y)];
    [self.scoreNode runAction:moveScoreNode completion:^{
        if (self.scoreNode.frame.origin.x > self.frame.size.width) {
            [self.scoreNode setPosition:CGPointMake(-CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
        }
    }];
    NSLog(@"GameNode.frame.origin.x: %f", self.gameNode.frame.origin.x);

    SKAction *moveGameNode = [SKEase MoveToWithNode:self.gameNode EaseFunction:CurveTypeCubic Mode:EaseOut Time:0.5f ToVector:CGVectorMake(self.gameNode.frame.origin.x + self.frame.size.width, self.gameNode.frame.origin.y)];
    [self.gameNode runAction:moveGameNode completion:^{
        NSLog(@"GameNode.frame.origin.x: %f", self.gameNode.frame.origin.x);
        if (self.gameNode.frame.origin.x >= self.frame.size.width) {
            [self.gameNode setPosition:CGPointMake(-self.frame.size.width, self.gameNode.frame.origin.y)];
        } else {
            [self.beginButton setEnabled:YES];
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
    
    int currentSeconds = (int)floor(timeInterval) % 60;
    int currentMilliseconds = (int)(timeInterval * 1000) % 1000;
    double tenths = (double)currentMilliseconds/10;
    int roundedMilliseconds = round(tenths) * 10;
    
    // Find the hit color for the floaty text
    UIColor *hitColor;
    hitColor = [UIColor gameEndingRed];
    
    NSInteger distanceToPerfect;
    NSInteger scoreForHit;
    
    // From 900--0 or 0-100
    if ((roundedMilliseconds >= MILLISECONDS_IN_SECOND - self.timeThreshold) || (roundedMilliseconds <= self.timeThreshold)) {
        
        if (roundedMilliseconds == 0 || roundedMilliseconds == 1000) {
            
            if (roundedMilliseconds == 1000) {
                if (currentSeconds == SECONDS_IN_MINUTE - 1) currentSeconds = 0;
                else currentSeconds += 1;
            }
            
            self.perfectHits++;
            
            NSLog(@"Perfect Hit at %d millisecond(s)!", (int)roundedMilliseconds);
            
            // Do the perfect animations
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self flashBackground:[UIColor perfectGreen]];
            
            distanceToPerfect = 0;
            
        } else if (roundedMilliseconds >= MILLISECONDS_IN_SECOND - self.timeThreshold) {

            NSLog(@"Under Hit at %d millisecond(s)!", (int)roundedMilliseconds);
            
            distanceToPerfect = MILLISECONDS_IN_SECOND - roundedMilliseconds;
            
        } else {

            NSLog(@"Over Hit at %d millisecond(s)!", (int)roundedMilliseconds);
            
            distanceToPerfect = roundedMilliseconds;
        }
        
        hitColor = [UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1];

    } else {
        
        self.missHits++;
        
        if (roundedMilliseconds >= MILLISECONDS_IN_SECOND/2) {
            distanceToPerfect = MILLISECONDS_IN_SECOND - roundedMilliseconds;
        } else {
            distanceToPerfect = roundedMilliseconds;
        }
    }
    
    if (distanceToPerfect > self.timeThreshold) {
        // Yield a negative score
        scoreForHit = -200;
    } else {
        // Yield a positive score
        scoreForHit =  self.timeThreshold - distanceToPerfect;
        scoreForHit *= SCORE_MULTIPLYING_FACTOR;
        if (distanceToPerfect == 0) scoreForHit *= 2;
    }
    
    NSLog(@"Score: %d", (int)scoreForHit);
    
    if (roundedMilliseconds >= 1000) roundedMilliseconds = 0;
    
    
    // Spawn a sprite of the time
    SKLabelNode *hitTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [hitTimeLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];

    if (scoreForHit < 0) {
        hitTimeLabel.text = [NSString stringWithFormat:@"%d", (int)scoreForHit];
    } else {
        hitTimeLabel.text = [NSString stringWithFormat:@"+%d", (int)scoreForHit];
    }
    
    hitTimeLabel.fontSize = FONT_SIZE;
    float yCoord = 0;
    if (isiPhone5) {
        yCoord = CGRectGetMidY(self.frame) + 30;
    } else {
        yCoord = CGRectGetMidY(self.frame);
    }
    [hitTimeLabel setPosition:CGPointMake(CGRectGetMidX(self.frame), yCoord)];
    [hitTimeLabel setFontColor:hitColor];
    [hitTimeLabel setZPosition:BUTTON_Z_LEVEL - 2];
    [self addChild:hitTimeLabel];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1.3f];
    SKAction *moveUp = [SKEase MoveToWithNode:hitTimeLabel EaseFunction:CurveTypeCubic Mode:EaseOut Time:1.3f ToVector:CGVectorMake(CGRectGetMidX(self.frame), yCoord + 100)];
    SKAction *tween = [SKAction group:[NSArray arrayWithObjects:fadeOut, moveUp, nil]];
    [hitTimeLabel runAction:tween completion:^{
        [hitTimeLabel removeFromParent];
    }];
    
    //update the score label
    self.score += scoreForHit;
    [self.scoreLabel setText:[NSString stringWithFormat:@"%d", (int)self.score]];
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
        [self.scoreLabel setText:@"0"];
        [self.gameTimeLabel setFontColor:[UIColor blackColor]];
        
        // Move the score out of the way
        [self animateScoreChange];
        
        [self.tapButton setHidden:YES];
        [self.beginButton setHidden:NO];
        [self.beginButton setEnabled:NO];
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
