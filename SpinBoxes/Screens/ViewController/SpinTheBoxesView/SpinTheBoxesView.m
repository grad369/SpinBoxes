//
//  SpinTheBoxesView.m
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "SpinTheBoxesView.h"
#import "BoxView.h"
#import "ComputatingManager.h"
#import "DynamicItem.h"

@interface SpinTheBoxesView() <BoxViewDelegate>
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat startMovedAngle;
@property (nonatomic, assign) BOOL animationRunning;

@property (nonatomic, strong) IBOutlet UIView *centerBoxView;
@property (nonatomic, strong) IBOutlet DynamicItem *dynamicItem;
@property (nonatomic, strong) IBOutletCollection(BoxView) NSArray *boxViews;
@end

@implementation SpinTheBoxesView

#pragma mark - View Life

- (void)dealloc
{
    NSLog(@"SpinTheBoxesView dealloc");
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    __block SpinTheBoxesView *selfId = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [selfId startPosition];
        [selfId.dynamicItem addDynamicsWithView:selfId];
    });
}

#pragma mark - Properties

-(void)setAngle:(CGFloat)angle
{
    _angle = angle;
    NSNotification *notification = [NSNotification notificationWithName:(NSString*)BoxViewChangeAlphaNotification object:@(angle)];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - |DynamicItemDelegate|

- (void)animatorDidPauseWithDynamicItem:(DynamicItem *)item
{
    _animationRunning = NO;
}

#pragma mark - |BoxViewDelegate|

- (void)boxView:(BoxView *)view swipeWithVelocity:(CGPoint)velocity
{
    _animationRunning = YES;
    _dynamicItem.center = view.center;
    [_dynamicItem removeAllBehaviors];
    
    __block SpinTheBoxesView *selfId = self;
    
    [_dynamicItem addLinearVelocity:velocity actionDynamicItemBehavior:^
    {
        if (selfId.animationRunning)
        {
            DynamicItem *dynamicItem = selfId.dynamicItem;
            
            CGPoint center = CGPointMake(dynamicItem.centerX, dynamicItem.centerY);
            CGFloat currentAngle = [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:center];
            selfId.angle = [COMPUTATION_MANAGER resetAngle:(currentAngle + selfId.startMovedAngle)];
            
            BOOL clockwise = [COMPUTATION_MANAGER isClockwiseWithAlpha:selfId.angle];
            CGPoint velocity =  dynamicItem.velocity;
            
            if (ABS(velocity.x) + ABS(velocity.y) < 35) {
                [selfId moveToFinishPositionWithClockwise:clockwise];
                [dynamicItem removeAllBehaviors];
            }
        }
    }];
}

- (void)touchesBeginOnBoxView:(BoxView *)view tapPointInSuperview:(CGPoint)point
{
    if (_animationRunning)
    {
        _animationRunning = NO;
        [_dynamicItem removeAllBehaviors];
    }
    
    _startMovedAngle = _angle - [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:point];
    
    if (_delegate != nil)
        [_delegate spinTheBoxesView:self tapOnView:view];
}

- (void)touchesMovedOnBoxView:(BoxView *)view tapPointInSuperview:(CGPoint)point
{
    _dynamicItem.center = view.center;
    CGFloat angleBoxView = [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:point];
    self.angle = [COMPUTATION_MANAGER resetAngle:(angleBoxView + _startMovedAngle)];
}

- (void)touchesEndedOnBoxView:(BoxView *)view
{
    [self moveToNearestPositionFrom:view.center];
}

- (void)longPressBeginOnBoxView:(BoxView *)view
{
    if (_delegate != nil)
        [_delegate spinTheBoxesView:self longPressBeginOnView:view];
}

- (void)longPressEndedOnBoxView:(BoxView *)view
{
    if (_delegate != nil)
        [_delegate spinTheBoxesView:self longPressEndedOnView:view];
    
    [self moveToNearestPositionFrom:view.center];
}

#pragma mark - Privates

- (void)startPosition
{
    self.height = self.width = [UIScreen mainScreen].bounds.size.width;
    
    ConfigurationBox c = [COMPUTATION_MANAGER setConfigurationWithView:self];
    
    self.angle = 0.0f;
    
    for (short i = 0; i < _boxViews.count; i++) {
        BoxView *view = _boxViews[i];
        CGFloat angle = (((CGFloat)i)/8*360 + self.angle);
        
        view.startAngle = angle;
        view.size = c.boxSize;
        view.delegate = self;
    }
    
    self.angle = 0.0f;
    
    _centerBoxView.size = c.boxSize;
    _centerBoxView.center = c.center;
    _dynamicItem.frame = ((BoxView *)_boxViews[0]).frame;
}

- (void)moveToNearestPositionFrom:(CGPoint)centerOfBoxView
{
    CGFloat angleBoxView = [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:centerOfBoxView];
    CGFloat nearestCenter = [COMPUTATION_MANAGER nearestAngleCenterBoxViewWithAlpha:(angleBoxView + _startMovedAngle)];
    
    [UIView animateWithDuration:0.8f animations:^{
        self.angle = nearestCenter;
    }];
}

- (void)moveToFinishPositionWithClockwise:(BOOL)isClockwise
{
    CGFloat angleBoxViewWithoutStartAngle = [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:_dynamicItem.center];
    CGFloat angleBoxViewWithStartAngle = [COMPUTATION_MANAGER resetAngle:(angleBoxViewWithoutStartAngle + _startMovedAngle)];
    CGFloat nearestAngleCenterOfBoxView = [COMPUTATION_MANAGER nearestAngleCenterBoxViewWithAlpha:angleBoxViewWithStartAngle
                                                                                        clockwise:isClockwise];

    CGFloat deltaAngle = 0;
    if (isClockwise)
        deltaAngle = [COMPUTATION_MANAGER resetAngle:(nearestAngleCenterOfBoxView + 360 - angleBoxViewWithStartAngle)];
    else
        deltaAngle = [COMPUTATION_MANAGER resetAngle:(angleBoxViewWithStartAngle + 360 - nearestAngleCenterOfBoxView)];
    
    CGFloat durationAnimation = deltaAngle / 10.0f;
    
    
    [UIView animateWithDuration:durationAnimation
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.angle = nearestAngleCenterOfBoxView;
     } completion:^(BOOL finished) {}];
}

@end
