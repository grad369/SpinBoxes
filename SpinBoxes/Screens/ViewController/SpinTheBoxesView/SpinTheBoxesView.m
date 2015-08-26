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

@interface SpinTheBoxesView() <UIDynamicAnimatorDelegate, BoxViewDelegate>
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, strong) IBOutlet UIView *centerBoxView;
@property (nonatomic, strong) IBOutlet DynamicItem *dynamicItem;
@property (nonatomic, strong) IBOutletCollection(BoxView) NSArray *boxViews;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, assign) BOOL animationRunning;
@property (nonatomic, assign) CGFloat startMovedAngle;
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startPosition];
        [self addDynamics];
    });
}

#pragma mark - Properties

-(void)setAngle:(CGFloat)angle
{
    _angle = angle;
    NSNotification *notification = [NSNotification notificationWithName:(NSString*)BoxViewChangeAlphaNotification object:@(angle)];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - |BoxViewDelegate|

- (void)boxView:(BoxView *)view swipeWithVelocity:(CGPoint)velocity
{
    _animationRunning = YES;
    [_animator removeAllBehaviors];
    _dynamicItem.center = view.center;
    [self setAttachmentBehavior];
    [self addLinearVelocity:velocity];
}

- (void)touchesBeginOnBoxView:(BoxView *)view tapPointInSuperview:(CGPoint)point
{
    if (_animationRunning)
    {
        _animationRunning = NO;
        [_animator removeAllBehaviors];
        [self setAttachmentBehavior];
    }
    
    _startMovedAngle = _angle - [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:point];
    
    if (_delegate != nil)
        [_delegate spinTheBoxesView:self tapOnView:view];
}

- (void)touchesMovedOnBoxView:(BoxView *)view tapPointInSuperview:(CGPoint)point
{
    _dynamicItem.center = view.center;
    CGFloat angleBoxView = [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:point];
    CGFloat alpha = (angleBoxView + _startMovedAngle);
    self.angle = [COMPUTATION_MANAGER resetAngle:alpha];
}

- (void)touchesEndedOnBoxView:(BoxView *)view
{
    [self moveToNearestPositionFrom:view.center];
}

- (void)addGravityToPoint:(CGPoint)point
{
    [_animator removeAllBehaviors];
    [self setAttachmentBehavior];
    
    CGFloat deltaX = point.x - _dynamicItem.centerX;
    CGFloat deltaY = point.y - _dynamicItem.centerY;
    
    CGVector vector = deltaX > deltaY ? CGVectorMake(1.0f, 0.0f) : CGVectorMake(0.0f, 1.0f);
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_dynamicItem]];
    gravityBehavior.gravityDirection = vector;
    gravityBehavior.action = ^{
        if (CGPointEqualToPoint(point, _dynamicItem.center)) {
            [_animator removeAllBehaviors];
        }
    };
    
    [_animator addBehavior:gravityBehavior];
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

#pragma mark - |UIDynamicAnimatorDelegate|

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator
{
    NSLog(@"===%@1", animator);
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
    _animationRunning = NO;
    
    NSLog(@"===%@2", animator);
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

- (void)addDynamics
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.animator.delegate = self;
    [self setAttachmentBehavior];
}

- (void)removeAllDynamicsItems
{
    [self removeLinearVelocity];
    [self removeAttachment];
}

- (void)removeAttachment
{
    [_animator removeBehavior:_dynamicItem.attachmentBehavior];
    _dynamicItem.attachmentBehavior = nil;
}

- (void)removeLinearVelocity
{
    [_animator removeBehavior:_dynamicItem.linearVelocityBehavior];
    _dynamicItem.linearVelocityBehavior = nil;
}

- (void)dynamicItemMoveToPoint:(CGPoint)point
{
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[_dynamicItem]];
    item.allowsRotation = NO;
    item.friction = 1;
    item.resistance = 0;
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_dynamicItem attachedToAnchor:point];
    attachmentBehavior.frequency = 0;
    attachmentBehavior.damping = 1;
    attachmentBehavior.length = 0;
    
    [_animator addBehavior:attachmentBehavior];
}

- (void)dynamicItemAttachmentToView:(UIView *)view
{
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[_dynamicItem]];
    item.allowsRotation = NO;
    item.friction = 1;
    item.resistance = 0;
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_dynamicItem attachedToItem:view];
    attachmentBehavior.frequency = 0;
    attachmentBehavior.damping = 1;
    attachmentBehavior.length = 0;
    
    [_animator addBehavior:attachmentBehavior];
}

- (void)setAttachmentBehavior
{
    if (_dynamicItem.attachmentBehavior != nil)
        [self removeAttachment];
    
    CGPoint attachmentPoint = CGPointMake(self.width/2, self.height/2);
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[_dynamicItem]];
    item.allowsRotation = NO;
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_dynamicItem attachedToAnchor:attachmentPoint];
    attachmentBehavior.frequency = 10;
    attachmentBehavior.damping = 2.5;
    [attachmentBehavior addChildBehavior:item];
    _dynamicItem.attachmentBehavior = attachmentBehavior;
    
    [_animator addBehavior:attachmentBehavior];
}

- (void)addSnapBehaviorToPoint:(CGPoint)point
{
    BOOL running = _animationRunning;
    _animationRunning = NO;
    
    UISnapBehavior *behavior = [[UISnapBehavior alloc] initWithItem:_dynamicItem snapToPoint:point];
    behavior.damping = 0.9;

    [_animator addBehavior:behavior];
    _dynamicItem.snapBehavior = behavior;
    
    _animationRunning = running;
}

- (void)addLinearVelocity:(CGPoint)velocity
{
    if (_dynamicItem.linearVelocityBehavior != nil)
        [self removeLinearVelocity];
    
    __block SpinTheBoxesView *selfId = self;
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[_dynamicItem]];
    [item addLinearVelocity:velocity forItem:_dynamicItem];
    item.density = 500;
    item.friction = 500;
    item.action = ^
    {
        if (selfId.animationRunning) {
            CGPoint center = CGPointMake(_dynamicItem.centerX, _dynamicItem.centerY);
            CGFloat currentAngle = [COMPUTATION_MANAGER alphaInDegreesForBoxWithPoint:center];
            self.angle = [COMPUTATION_MANAGER resetAngle:(currentAngle + _startMovedAngle)];
            
            BOOL clockwise = [COMPUTATION_MANAGER isClockwiseWithAlpha:_angle];
            CGPoint velocity = [_dynamicItem.linearVelocityBehavior linearVelocityForItem:_dynamicItem];
            
            if (ABS(velocity.x) + ABS(velocity.y) < 35) {
                
                
                [selfId moveToFinishPositionWithClockwise:clockwise];
                [_animator removeAllBehaviors];
                [self setAttachmentBehavior];
            }
        }
    };
    
    [_animator updateItemUsingCurrentState:_dynamicItem];
    [_animator addBehavior:item];
    _dynamicItem.linearVelocityBehavior = item;
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
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.angle = nearestAngleCenterOfBoxView;
     } completion:^(BOOL finished) {}];
}

@end
