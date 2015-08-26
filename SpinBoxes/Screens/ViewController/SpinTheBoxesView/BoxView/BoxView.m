//
//  ContainerBoxView.m
//  SpinTheBoxes
//
//  Created by vaskov on 08.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "BoxView.h"
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
}

- (void)awakeFromNib
{
    _titleText = [_titleLabel.text copy];
    
    [self addRecognizers];
    [self addObserver];
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

#pragma mark - Actions

- (void)swipeOnView:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (_delegate != nil)
            {
                CGPoint point = [recognizer locationInView:self.superview];
                [_delegate touchesMovedOnBoxView:self tapPointInSuperview:point];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (_delegate != nil)
            {
                CGPoint velocity = [recognizer velocityInView:self];
                [_delegate boxView:self swipeWithVelocity:CGPointMake(velocity.x, velocity.y)];
            }
            break;
        }
        default:
            break;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (_delegate != nil && recognizer.state == UIGestureRecognizerStateBegan)
        [_delegate longPressBeginOnBoxView:self];
    
    if (_delegate != nil && recognizer.state == UIGestureRecognizerStateEnded)
        [_delegate longPressEndedOnBoxView:self];
}

#pragma mark - |UIResponder|

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if (_delegate != nil)
    {
        UITouch *touch = [touches anyObject];
        CGPoint tapPoint = [touch locationInView:self.superview];
        [_delegate touchesBeginOnBoxView:self tapPointInSuperview:tapPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate != nil)
    {
        UITouch *touch = [touches anyObject];
        CGPoint tapPoint = [touch locationInView:self.superview];
        [_delegate touchesMovedOnBoxView:self tapPointInSuperview:tapPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate != nil)
    {
        [_delegate touchesEndedOnBoxView:self];
    }
    
    NSLog(@"touchesEnded");
}

#pragma mark - Privates

- (void)addRecognizers
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOnView:)];
    [self addGestureRecognizer:panRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPressRecognizer];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserverForName:(NSString*)BoxViewChangeAlphaNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification)
     {
         CGFloat currentAngle = [notification.object floatValue] + _startAngle;
         self.center = [COMPUTATION_MANAGER centerBoxViewWithAlpha:currentAngle];
     }];
}

@end
