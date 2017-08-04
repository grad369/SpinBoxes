//
//  ViewController.m
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "ViewController.h"
#import "SpinBoxesView.h"
#import "BoxView.h"
#import "UIView+Helpers.h"

@interface ViewController ()<SpinBoxesViewDelegate>
@property (weak, nonatomic) IBOutlet SpinBoxesView *spinBoxesView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation ViewController

#pragma mark - View life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _spinBoxesView.origin = CGPointMake(0, 50);
    _spinBoxesView.delegate = self;
    
    _label.origin = CGPointMake(0, _spinBoxesView.bottom + 100);
    _label.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 100);
}

#pragma mark - |SpinBoxesViewDelegate|

- (void)spinBoxesView:(SpinBoxesView *)view tapOnView:(BoxView *)boxView
{
    _label.text = [NSString stringWithFormat:@"Tap #%@", boxView.titleText];
    
    [self hideText];
}

- (void)spinBoxesView:(SpinBoxesView *)view longPressBeginOnView:(BoxView *)boxView
{
    _label.text = [NSString stringWithFormat:@"Longpress start #%@", boxView.titleText];
    
    [self hideText];
}

- (void)spinBoxesView:(SpinBoxesView *)view longPressEndedOnView:(BoxView *)boxView
{
    _label.text = [NSString stringWithFormat:@"End Longpress #%@", boxView.titleText];
    
    [self hideText];
}

#pragma mark - Privates

- (void)hideText
{
    _label.alpha = 1.0f;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideTextAnimation) withObject:nil afterDelay:2.0f];
}

- (void)hideTextAnimation
{
    [UIView animateWithDuration:0.5 animations:^{
        _label.alpha = 0;
    } completion:^(BOOL finished) {
        //_label.text = @"";
    }];
}

@end
