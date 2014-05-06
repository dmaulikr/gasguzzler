//
//  SKSpriteButton.h
//  LineOfSight
//
//  Created by Raymond Kennedy on 8/24/13.
//  Copyright (c) 2013 Raymond Kennedy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SKSpriteButton;

@protocol SKSpriteButtonDelegate <NSObject>

- (void)buttonHit:(SKSpriteButton *)button;

@end

@interface SKSpriteButton : SKSpriteNode

typedef enum buttonModes {
    kTouchUpInside,
    kTouchDownInside
} ButtonMode;

@property (nonatomic, strong) id <SKSpriteButtonDelegate>delegate;

@property (nonatomic, strong) NSString *upImage;
@property (nonatomic, strong) NSString *downImage;
@property (nonatomic, strong) NSString *disabledImage;

@property (nonatomic) int tag;
@property (nonatomic) BOOL enabled;

+ (SKSpriteButton *)spriteButtonWithUpImage:(NSString *)upImage downImage:(NSString *)downImage disabledImage:(NSString *)disabledImage buttonMode:(ButtonMode)buttonMode;

@end
