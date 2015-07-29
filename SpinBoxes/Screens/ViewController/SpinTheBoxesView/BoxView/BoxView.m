//
//  ContainerBoxView.m
//  SpinTheBoxes
//
//  Created by vaskov on 08.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "BoxView.h"
#import "MTKObserving.h"
#import "ComputatingManager.h"

NSString const *BoxViewChangeAlphaNotification = @"BoxViewChangeAlphaNotification";

@interface BoxView ()
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@end

@implementation BoxView

#pragma mark - View Life

- (void)dealloc
{
    NSLog(@"BoxView dealloc");
    [self removeAllObservations];
}

- (void)awakeFromNib
{
    _titleText = [_titleLabel.text copy];
    //_titleLabel.center = CGPointMake(self.width/2, self.height/2);
    
//    void (^block)(UISwipeGestureRecognizerDirection direction) = ^(UISwipeGestureRecognizerDirection direction)
//    {
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOnView:)];
        //recognizer.direction = direction;
        [self addGestureRecognizer:recognizer];
//    };
//    
//    block(UISwipeGestureRecognizerDirectionRight);
//    block(UISwipeGestureRecognizerDirectionLeft);
//    block(UISwipeGestureRecognizerDirectionDown);
//    block(UISwipeGestureRecognizerDirectionUp);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:(NSString*)BoxViewChangeAlphaNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        //if (!self.activeBox)
        {
            _currentAngle = [notification.object floatValue] + _startAngle;
            self.center = [ComputatingManager centerBoxViewWithAlpha:_currentAngle];
        }
    }];
}

- (void)layoutSubviews
{
    _titleLabel.center = CGPointMake(self.width/2, self.height/2);
}

#pragma mark - Properties

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    _titleLabel.text = titleText;
}

#pragma mark - Privates

- (void)swipeOnView:(UIPanGestureRecognizer *)recognizer
{    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(boxView:swipeWithVelocity:)])
    {
        CGPoint velocity = [recognizer velocityInView:self];
        [_delegate boxView:self swipeWithVelocity:CGPointMake(velocity.x/10, velocity.y/10)];
    }
}



@end
