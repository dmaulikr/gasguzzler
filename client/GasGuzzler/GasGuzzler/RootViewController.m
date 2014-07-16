//
//  RootViewController.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/4/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "RootViewController.h"
#import "MenuScene.h"

#import <iAd/iAd.h>

@interface RootViewController () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show the iAd
    self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    [self.bannerView setDelegate:self];
    [self.view addSubview:self.bannerView];
    
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [self bannerView:self.bannerView didFailToReceiveAdWithError:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

/*
 * iAd Failed
 */
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"iAd failed");
}

@end
