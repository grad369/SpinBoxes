//
//  SpinTheBoxesView.m
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "SpinTheBoxesView.h"
#import "TapView.h"
#import "BoxView.h"
#import "ComputatingManager.h"

@interface SpinTheBoxesView() <TapViewDelegate, UIDynamicAnimatorDelegate, BoxViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *centerBoxView;
@property (nonatomic, strong) IBOutletCollection(BoxView) NSArray *boxViews;
@property (nonatomic, assign) CGFloat startAngle;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) NSMutableArray *dynamicsItems;
@property (nonatomic, assign) BOOL animationRunning;
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

//#pragma mark - |TapViewDelegate|
//
//- (void)tapViewWillStartRotating:(TapView *)tapView
//{
//    _startAngle = self.angle;
//}
//
//- (void)tapViewRotating:(TapView *)tapView deltaAlpha:(CGFloat)theDeltaAlpha clockwise:(BOOL)theClockwise
//{
//    CGFloat angle = _startAngle + (theClockwise ? ABS(theDeltaAlpha) : -ABS(theDeltaAlpha));
//    self.angle = angle;
//}
//
//- (void)tapViewWillStartDecelerating:(TapView *)tapView velocity:(CGPoint)point clockwise:(BOOL)isClockwise
//{
//    BOOL directionHorisontal = ABS(point.x) > ABS(point.y);
//    CGFloat duration = 0.1/(directionHorisontal ? point.x : point.y);
//    if (duration < 0.0001f) 
//        duration = 0.0001f;
//    if (duration > 0.003f)
//        duration = 0.01f;
//    
//    [self changeAngle:self.angle  duration:duration step:0.0001f clockwise:(BOOL)isClockwise];
//}
//
//- (void)tapViewDidFinishedRotating:(TapView *)tapView
//{
//    _angle = [CalculationManager resetAngle:self.angle];
//}
//
//- (void)tapViewWithTapRecognizer:(TapView *)tapView point:(CGPoint)thePoint
//{
//    BoxView *boxView = [self selectBoxViewithPoint:thePoint];
//    
//    if (boxView != nil) 
//        [self showMessage:[NSString stringWithFormat:@"Tap #%@", boxView.titleText]];
//}
//
//- (void)tapViewWithLongTapRecognizer:(TapView *)tapView point:(CGPoint)thePoint
//{
//    BoxView *boxView = [self selectBoxViewithPoint:thePoint];
//    
//    if (boxView != nil)
//        [self showMessage:[NSString stringWithFormat:@"Longpress start #%@", boxView.titleText]];
//}
//
//- (void)tapViewWithLongTapFinishedRecognizer:(TapView *)tapView point:(CGPoint)thePoint
//{
//    BoxView *boxView = [self selectBoxViewithPoint:thePoint];
//    
//    if (boxView != nil)
//        [self showMessage:[NSString stringWithFormat:@"End Longpress #%@", boxView.titleText]];
//}

#pragma mark - |BoxViewDelegate|

- (void)boxView:(BoxView *)view swipeWithVelocity:(CGPoint)velocity
{
    [self removeAllDynamicsItems];
   
    NSLog(@"=====%@++++++", NSStringFromCGPoint(velocity));
    //view.activeBox = YES;
    _animationRunning = YES;
    
    [self setAttachmentBehaviors];
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
    //__block UIDynamicItemBehavior *item1 = item;
    
    
    [item addLinearVelocity:velocity forItem:view];
    item.density = 50;
    item.friction = 50;
    item.allowsRotation = NO;
    item.action = ^
    {
      //  static UISnapBehavior *snapBehavior = nil;
        //static BOOL isClockwise = YES, first = YES;
        //static NSInteger countEnters = 0;
        
        if (self.animationRunning) {
            CGPoint center = CGPointMake(view.centerX, view.centerY);
            
//
            //NSLog(@"-----%@", @(isClockwise));
            CGFloat currentAngle = [ComputatingManager alphaInDegreesForBoxWithCenter:center];
            self.angle = [ComputatingManager resetAngle:(currentAngle)];
//            
//            CGPoint velocity = [item1 linearVelocityForItem:view];
//           
//            
//            if (ABS(velocity.x) + ABS(velocity.y) < 40 && first)
//            {
//                first = NO;
//                
//                
//                    //[_animator removeAllBehaviors];
            //[_animator removeBehavior:self.dynamicsItems.firstObject];
            //[_dynamicsItems removeAllObjects];
            
            //CGPoint centerNextStopBoxView = [ComputatingManager finishCenterBoxViewWithAlpha:_angle];
//          snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:centerNextStopBoxView];
//          snapBehavior.damping = 1;
           // UIGravityBehavior *gravityBehavior = [UIGravityBehavior new];
            //gravityBehavior.gravityDirection = CGVectorMake(1, 1);
//                                    //[view.attachmentBehavior addChildBehavior:snapBehavior];
//                    [_animator addBehavior:snapBehavior];
                    //[_animator removeBehavior:item1];
                
                
           // }
            //NSLog(@"-----%@", NSStringFromCGPoint([item1 linearVelocityForItem:view]));
             //NSLog(@"-----%@", NSStringFromCGPoint(centerNextStopBoxView));
        }
        else
        {
            //[view.attachmentBehavior removeChildBehavior:snapBehavior];
           // first = YES;
        }
    };
    
    [_dynamicsItems addObject:item];
    [_animator addBehavior:item];
    
    //NSLog(@"%@ == %@", obj, _animator);

}

#pragma mark - |UIDynamicAnimatorDelegate|

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator
{
    //[self removeAllDynamicsItems];
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
    self.center = self.superview.center;
    
    ConfigurationBox c = [ComputatingManager setConfigurationWithView:self];
    
    _centerBoxView.size = c.boxSize;
    _centerBoxView.center = c.center;
    
    self.angle = 0.0f;
    
    for (short i = 0; i < _boxViews.count; i++) {
        BoxView *view = _boxViews[i];
        CGFloat angle = (((CGFloat)i)/8*360 + self.angle);
        
        view.startAngle = angle;
        view.size = c.boxSize;
        view.delegate = self;
    }
    
    self.angle = 0.0f;
}

- (void)addDynamics
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.animator.delegate = self;
    self.dynamicsItems = [NSMutableArray new];
    return;
    CGPoint attachmentPoint = CGPointMake(self.width/2, self.height/2);
    
    for (BoxView *view in _boxViews) {
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:attachmentPoint];
        attachmentBehavior.frequency = 10;
        attachmentBehavior.damping = 2.5;
        view.attachmentBehavior = attachmentBehavior;
        [_animator addBehavior:attachmentBehavior];
    };
}

- (void)removeAllDynamicsItems
{
    for (UIDynamicItemBehavior *behavior in _dynamicsItems) {
        BoxView *view = behavior.items.firstObject;
        //view.activeBox = NO;
        [_animator removeBehavior:behavior];
    }
    
    [_dynamicsItems removeAllObjects];
}

- (void)setAttachmentBehaviors
{
    CGPoint attachmentPoint = CGPointMake(self.width/2, self.height/2);
    
    for (BoxView *boxView in _boxViews) {
        UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[boxView]];
        item.allowsRotation = NO;
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:boxView attachedToAnchor:attachmentPoint];
        attachmentBehavior.frequency = 10;
        attachmentBehavior.damping = 2.5;
        [attachmentBehavior addChildBehavior:item];
        boxView.attachmentBehavior = attachmentBehavior;
        [_animator addBehavior:attachmentBehavior];
    };
}

//- (void)changeAngle:(CGFloat)startAngle duration:(CGFloat)duration step:(CGFloat)step clockwise:(BOOL)isClockwise
//{
//    if (duration >= 0.01) {
//        [self finishChangingAngle:isClockwise];
//        return;
//    }
//    
//    self.angle = startAngle;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self changeAngle:(startAngle + (isClockwise ? 1 : -1)) duration:(duration+step) step:step clockwise:isClockwise];
//    });
//}
//

//- (CGPoint)finishCenterBoxViewChangingAngle:(BOOL)isClockwise
//{
//    NSInteger index = 0;
//    
//    CGFloat currentAngle = [ComputatingManager resetAngle:self.angle];
//    
//    while (currentAngle > 0) {
//        currentAngle -= 45;
//        index++;
//    }
//    
//    NSArray *angles = @[@(0), @(45), @(90), @(135), @(180), @(225), @(270), @(315)];
//    
//    if (isClockwise) {
//        if (index > (angles.count - 1))
//            index = 0;
//    }
//    else {
//        if (--index < 0) {
//            index = (angles.count - 1);
//        }
//    }
//    
//    return [ComputatingManager centerBoxViewWithAlpha:[angles[index] floatValue]];
//}

//
//- (BoxView *)selectBoxViewithPoint:(CGPoint)point
//{
//    BoxView *selectBoxView = nil;
//    for (BoxView *view in _boxViews) {
//        if (CGRectContainsPoint(view.frame, point)) {
//            selectBoxView = view;
//            break;
//        }
//    }
//    
//    return selectBoxView;
//}
//
//- (void)showMessage:(NSString *)text
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message"
//                                                        message:text
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles: nil];
//    [alertView show];
//    NSLog(@"Log message: %@", text);
//}

@end