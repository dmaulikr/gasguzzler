//
//  InfinityScoreNode.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/12/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "InfinityScoreNode.h"
#import "UIColor+Extensions.h"

@interface InfinityScoreNode ()

@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, strong) SKLabelNode *perfects;
@property (nonatomic, strong) SKLabelNode *losingTime;

@end

@implementation InfinityScoreNode

static const NSInteger FONT_SIZE = 75;

/*
 * Returns a new score node
 */
+ (InfinityScoreNode *)scoreNodeWithScore:(NSInteger)score perfects:(NSInteger)perfectHits
{
    InfinityScoreNode *sn = [[InfinityScoreNode alloc] init];
    
    // Setup the score label and nickname label
    sn.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [sn.scoreLabel setFontColor:[UIColor scoreTurqoise]];
    [sn.scoreLabel setFontSize:FONT_SIZE];
    [sn.scoreLabel setPosition:CGPointMake(CGRectGetMidX(sn.frame), CGRectGetMidY(sn.frame) + 100)];
    [sn.scoreLabel setText:[NSString stringWithFormat:@"%d taps", (int)score]];
    [sn addChild:sn.scoreLabel];
    
    // SEtup the perfects label
    sn.perfects = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [sn.perfects setFontColor:[UIColor perfectGreen]];
    [sn.perfects setFontSize:FONT_SIZE];
    [sn.perfects setPosition:CGPointMake(CGRectGetMidX(sn.frame), CGRectGetMidY(sn.frame) + 25)];
    [sn.perfects setText:[NSString stringWithFormat:@"%d perfects", (int)perfectHits]];
    [sn addChild:sn.perfects];
    
    // Setup the losing time
    sn.losingTime = [SKLabelNode labelNodeWithFontNamed:@"AmericanCaptain"];
    [sn.losingTime setFontColor:[UIColor gameEndingRed]];
    [sn.losingTime setFontSize:FONT_SIZE];
    [sn.losingTime setPosition:CGPointMake(CGRectGetMidX(sn.frame), CGRectGetMidY(sn.frame) - 50)];
    [sn.losingTime setText:[NSString stringWithFormat:@"00.00.00"]];
    [sn addChild:sn.losingTime];
    
    return sn;
}

/*
 * Change the score label of the score node
 */
- (void)setScore:(NSInteger)score perfects:(NSInteger)perfects losingTime:(NSString *)losingTime
{
    if (score != 1) {
        [self.scoreLabel setText:[NSString stringWithFormat:@"%d taps", (int)score]];
    } else {
        [self.scoreLabel setText:[NSString stringWithFormat:@"%d tap", (int)score]];
    }
    
    if (perfects != 1) {
        [self.perfects setText:[NSString stringWithFormat:@"%d perfects", (int)perfects]];
    } else {
        [self.perfects setText:[NSString stringWithFormat:@"%d perfect", (int)perfects]];
    }
    
    [self.losingTime setText:losingTime];
}

@end
