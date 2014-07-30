//
//  HelpView.h
//  GasGuzzler
//
//  Created by franzwarning on 7/29/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HelpView;

@protocol HelpViewDelegate <NSObject>

- (void)didExitHelpView;

@end


@interface HelpView : UIView

@property (nonatomic, strong) id <HelpViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame gameMode:(NSString *)gameMode;

@end
