//
//  SKSpriteButton.m
//  LineOfSight
//
//  Created by Raymond Kennedy on 8/24/13.
//  Copyright (c) 2013 Raymond Kennedy. All rights reserved.
//

#import "SKSpriteButton.h"

@interface SKSpriteButton()

@property (nonatomic, strong) SKSpriteNode *downSprite;
@property (nonatomic, strong) SKSpriteNode *disabledSprite;
@property (nonatomic, strong) SKSpriteNode *upSprite;

@property (nonatomic) ButtonMode bm;

@property (nonatomic) BOOL isOnButton;

@end

@implementation SKSpriteButton



+ (SKSpriteButton *)spriteButtonWithUpImage:(NSString *)upImage downImage:(NSString *)downImage disabledImage:(NSString *)disabledImage buttonMode:(ButtonMode)buttonMode
{
    SKSpriteButton *newButton = [[SKSpriteButton alloc] initWithColor:[UIColor clearColor] size:[UIImage imageNamed:upImage].size];
    newButton.upImage = upImage;
    newButton.downImage = downImage;
    newButton.disabledImage = disabledImage;
    newButton.bm = buttonMode;
    
    SKSpriteNode *upSprite = [SKSpriteNode spriteNodeWithImageNamed:upImage];
    newButton.upSprite = upSprite;
    [newButton addChild:upSprite];
    
    SKSpriteNode *downSprite = [SKSpriteNode spriteNodeWithImageNamed:downImage];
    newButton.downSprite = downSprite;
    [newButton addChild:downSprite];
    
    if (!disabledImage || [disabledImage isEqualToString:@""]) disabledImage = @"disabledImage";
    SKSpriteNode *disabledSprite = [SKSpriteNode spriteNodeWithImageNamed:disabledImage];
    newButton.disabledSprite = disabledSprite;
    [newButton addChild:disabledSprite];
    
    [newButton setEnabled:YES];
    
    return newButton;
}

- (void)setEnabled:(BOOL)enabled
{
    if (enabled) {
        [self setUserInteractionEnabled:YES];
        self.upSprite.hidden = NO;
        self.downSprite.hidden = YES;
        self.disabledSprite.hidden = YES;
    } else {
        [self setUserInteractionEnabled:NO];
        self.upSprite.hidden = YES;
        self.downSprite.hidden = YES;
        self.disabledSprite.hidden = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.downSprite.hidden = NO;
    self.upSprite.hidden = YES;
    self.isOnButton = true;
    
    if (self.bm == kTouchDownInside) {
        if ([self.delegate respondsToSelector:@selector(buttonHit:)]) {
            [self.delegate buttonHit:self];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:(SKNode *)self.delegate];
    
    if (CGRectContainsPoint(self.frame, location)) {
        self.downSprite.hidden = NO;
        self.upSprite.hidden = YES;
        self.isOnButton = true;
    } else {
        self.downSprite.hidden = YES;
        self.upSprite.hidden = NO;
        self.isOnButton = false;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.isOnButton) {
        
        // Pass the message to the delegate
        if (self.bm == kTouchUpInside) {
            if ([self.delegate respondsToSelector:@selector(buttonHit:)]) {
                [self.delegate buttonHit:self];
            }
        }
        
    }
    self.downSprite.hidden = YES;
    self.upSprite.hidden = NO;
}

- (CGFloat)getHeight
{
    return [UIImage imageNamed:self.upImage].size.height;
}

- (CGFloat)getWidth
{
    return [UIImage imageNamed:self.upImage].size.width;

}

@end
