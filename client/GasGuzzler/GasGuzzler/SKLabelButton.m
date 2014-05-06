//
//  SKLabelButton.m
//  LineOfSight
//
//  Created by Raymond Kennedy on 8/21/13.
//  Copyright (c) 2013 Raymond Kennedy. All rights reserved.
//

#import "SKLabelButton.h"

@interface SKLabelButton ()

@property (nonatomic, strong) UIColor *upColor;
@property (nonatomic) BOOL isOnButton;
@end

@implementation SKLabelButton

+ (SKLabelButton *)buttonWithDownColor:(UIColor *)downColor {
    SKLabelButton *newSKLabelButton = [[SKLabelButton alloc] init];
    newSKLabelButton.downColor = downColor;
    return newSKLabelButton;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.upColor = self.fontColor;
    self.fontColor = self.downColor;
    self.isOnButton = true;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:(SKNode *)self.delegate];

    if (CGRectContainsPoint(self.frame, location)) {
        self.fontColor = self.downColor;
        self.isOnButton = true;
    } else {
        self.fontColor = self.upColor;
        self.isOnButton = false;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isOnButton) {
        if ([self.delegate respondsToSelector:@selector(labelButtonHit:)]) {
            [self.delegate labelButtonHit:self];
        }
    }
    self.fontColor = self.upColor;
}

@end
