//
//  SKLabelButton.h
//  LineOfSight
//
//  Created by Raymond Kennedy on 8/21/13.
//  Copyright (c) 2013 Raymond Kennedy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SKLabelButton;

@protocol SKLabelButtonDelegate <NSObject>

- (void)buttonHit:(SKLabelButton *)button;

@end

@interface SKLabelButton : SKLabelNode

@property (nonatomic, strong) UIColor *downColor;
@property (nonatomic, strong) id <SKLabelButtonDelegate>delegate;

+ (SKLabelButton *)buttonWithDownColor:(UIColor *)downColor;

@end
