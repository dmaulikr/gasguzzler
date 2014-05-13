//
//  ThirtyScoreNode.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/12/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "ThirtyScoreNode.h"
#import "UIColor+Extensions.h"

@interface ThirtyScoreNode ()

@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *perfects;
@property (nonatomic, strong) SKLabelNode *missedHits;

@end

@implementation ThirtyScoreNode

static const NSInteger FONT_SIZE = 75;

/*
 * Returns a new score node
 */
+ (ThirtyScoreNode *)scoreNodeWithScore:(NSInteger)score perfects:(NSInteger)perfectHits
{
    ThirtyScoreNode *tsn = [[ThirtyScoreNode alloc] init];
    
    // Setup the score label and nickname label
    tsn.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [tsn.scoreLabel setFontColor:[UIColor scoreTurqoise]];
    [tsn.scoreLabel setFontSize:FONT_SIZE];
    [tsn.scoreLabel setPosition:CGPointMake(CGRectGetMidX(tsn.frame), CGRectGetMidY(tsn.frame) + 100)];
    [tsn.scoreLabel setText:[NSString stringWithFormat:@"%d", (int)score]];
    [tsn addChild:tsn.scoreLabel];
    
    // SEtup the perfects label
    tsn.perfects = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [tsn.perfects setFontColor:[UIColor perfectGreen]];
    [tsn.perfects setFontSize:FONT_SIZE];
    [tsn.perfects setPosition:CGPointMake(CGRectGetMidX(tsn.frame), CGRectGetMidY(tsn.frame) + 25)];
    [tsn.perfects setText:[NSString stringWithFormat:@"%d perfects", (int)perfectHits]];
    [tsn addChild:tsn.perfects];
    
    // Setup the losing time
    tsn.missedHits = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [tsn.missedHits setFontColor:[UIColor gameEndingRed]];
    [tsn.missedHits setFontSize:FONT_SIZE];
    [tsn.missedHits setPosition:CGPointMake(CGRectGetMidX(tsn.frame), CGRectGetMidY(tsn.frame) - 50)];
    [tsn.missedHits setText:[NSString stringWithFormat:@"0 missed"]];
    [tsn addChild:tsn.missedHits];
    
    return tsn;
}

/*
 * Change the score label of the score node
 */
- (void)setScore:(NSInteger)score perfects:(NSInteger)perfects missedHits:(NSInteger)missedHits
{
    if (score != 1) {
        [self.scoreLabel setText:[NSString stringWithFormat:@"%d", (int)score]];
    } else {
        [self.scoreLabel setText:[NSString stringWithFormat:@"%d", (int)score]];
    }
    
    if (perfects != 1) {
        [self.perfects setText:[NSString stringWithFormat:@"%d perfects", (int)perfects]];
    } else {
        [self.perfects setText:[NSString stringWithFormat:@"%d perfect", (int)perfects]];
    }
    
    [self.missedHits setText:[NSString stringWithFormat:@"%d missed", (int)missedHits]];
}

@end
