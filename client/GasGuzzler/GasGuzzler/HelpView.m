//
//  HelpView.m
//  GasGuzzler
//
//  Created by franzwarning on 7/29/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "HelpView.h"

static const CGFloat kHelpViewHeight = 280;
static const CGFloat kHelpViewWidth = 280;
static const CGFloat kHelpViewXPadding = 20;
static const CGFloat kHelpLabelPadding = 10;

@interface HelpView () {
    UILabel *_helpLabel;
    UIView *_helpView;
    UIView *_opacityView;
}

@end

@implementation HelpView

- (id)initWithFrame:(CGRect)frame gameMode:(NSString *)gameMode
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUserInteractionEnabled:YES];
        
        _opacityView = [[UIView alloc] initWithFrame:self.frame];
        [_opacityView setBackgroundColor:[UIColor blackColor]];
        [_opacityView setAlpha:0.4f];
        [self addSubview:_opacityView];
        
        _helpView = [[UIView alloc] initWithFrame:CGRectMake(kHelpViewXPadding, CGRectGetMidY(self.frame) - kHelpViewHeight/2, kHelpViewWidth, kHelpViewHeight)];
        [_helpView setBackgroundColor:[UIColor blackColor]];
        [_helpView.layer setCornerRadius:10.0f];
        [_helpView.layer setMasksToBounds:YES];
        [_helpView setAlpha:0.90f];
        [self addSubview:_helpView];
        
        _helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHelpLabelPadding, kHelpLabelPadding, kHelpViewWidth - kHelpLabelPadding*2, kHelpViewHeight - kHelpLabelPadding)];
        [_helpLabel setFont:[UIFont fontWithName:@"AmericanCaptain" size:40.0f]];
        [_helpLabel setTextAlignment:NSTextAlignmentCenter];
        [_helpLabel setTextColor:[UIColor whiteColor]];
        [_helpLabel setNumberOfLines:6];
        
        NSMutableAttributedString *instructions = nil;
        
        if ([gameMode isEqualToString:@"thirty"]) {
            instructions = [[NSMutableAttributedString alloc] initWithString:@"Hit the TAP button as close to the second mark as you can. Close taps get a higher score!"];
            [instructions addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.61 green:0.35 blue:0.71 alpha:1] range:NSMakeRange(8, 3)];
            [instructions addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1] range:NSMakeRange(35, 7)];
            [instructions addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.1 green:0.74 blue:0.61 alpha:1] range:NSMakeRange(83, 5)];
        } else {
            instructions = [[NSMutableAttributedString alloc] initWithString:@"Hit the TAP button as close to the second mark as you can. You must be within 10 milliseconds!"];
            [instructions addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.61 green:0.35 blue:0.71 alpha:1] range:NSMakeRange(8, 3)];
            [instructions addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1] range:NSMakeRange(35, 7)];
            [instructions addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.91 green:0.3 blue:0.24 alpha:1] range:NSMakeRange(78, 2)];
        }

        
        [_helpLabel setAttributedText:instructions];
        [_helpView addSubview:_helpLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView* viewYouWishToObtain = [self hitTest:locationPoint withEvent:event];
    if (viewYouWishToObtain != _helpView) {
        if ([self.delegate respondsToSelector:@selector(didExitHelpView)]) {
            [self.delegate didExitHelpView];
        }
    }
}

@end
