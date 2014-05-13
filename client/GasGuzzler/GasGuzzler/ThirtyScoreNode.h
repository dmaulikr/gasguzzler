//
//  ThirtyScoreNode.h
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/12/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ThirtyScoreNode : SKNode

+ (ThirtyScoreNode *)scoreNodeWithScore:(NSInteger)score perfects:(NSInteger)perfectHits;
- (void)setScore:(NSInteger)score perfects:(NSInteger)perfects missedHits:(NSInteger)missedHits;

@end
