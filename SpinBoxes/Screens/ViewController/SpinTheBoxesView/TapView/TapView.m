//
//  TapView.m
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "TapView.h"
#import "MTKObserving.h"

typedef NS_ENUM(NSInteger, Rotating)
{
    RotatingNone,
    RotatingClockwise,
    RotatingCounterClockwise
};

@interface TapView ()
@property (nonatomic, assign) BOOL directionHorisontal;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) Rotating rotating;
@end

@implementation TapView

#pragma mark - View Life

- (void)dealloc
{
    NSLog(@"TapView dealloc");
}

- (void)awakeFromNib
{
    _rotating = RotatingNone;
}

#pragma mark - |UIResponder|

- (IBAction)tap:(id)sender
{
    CGPoint point = [sender locationInView:self.superview];
    
    if ([_delegate respondsToSelector:@selector(tapViewWithTapRecognizer:point:)])
        [_delegate tapViewWithTapRecognizer:self point:point];
}

- (IBAction)longTap:(UILongPressGestureRecognizer *)sender
{
    __block CGPoint point = [sender locationInView:self.superview];
    
    [sender observeProperty:@"state" withBlock:^(id self, id old, id newVal) {
        
        if ([newVal integerValue] == 1 && old == nil) {
            if ([_delegate respondsToSelector:@selector(tapViewWithLongTapRecognizer:point:)])
                [_delegate tapViewWithLongTapRecognizer:self point:point];
            [self removeAllObservations];
        }
        
        if ([newVal integerValue] > 2 && old == nil) {
            if ([_delegate respondsToSelector:@selector(tapViewWithLongTapFinishedRecognizer:point:)])
                [_delegate tapViewWithLongTapFinishedRecognizer:self point:point];
            
            [self removeAllObservations];
        }
    }];
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.superview];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _startPoint = point;
        if ([_delegate respondsToSelector:@selector(tapViewWillStartRotating:)])
                    [_delegate tapViewWillStartRotating:self];
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        
        [self checkDirectionAndClockwiseWithPoint:point];
        
        if (_rotating == RotatingNone)
            return;
        
        CGFloat delta = _directionHorisontal ? (point.x - _startPoint.x) : (point.y - _startPoint.y);
        
        if ([_delegate respondsToSelector:@selector(tapViewRotating:deltaAlpha:clockwise:)]) {
            [_delegate tapViewRotating:self deltaAlpha:ABS(delta)*0.5f clockwise:_rotating == RotatingClockwise];
        }
    }
    else{
        CGPoint velocity = [sender velocityInView:self];
        
        if ([_delegate respondsToSelector:@selector(tapViewWillStartDecelerating:velocity:clockwise:)])
            [_delegate tapViewWillStartDecelerating:self velocity:velocity clockwise:_rotating == RotatingClockwise];
        
        _rotating = RotatingNone;
    }
}

#pragma mark - Privates

- (void)checkDirectionAndClockwiseWithPoint:(CGPoint)point
{
    static CGPoint oldPoint;
    
    if (CGPointEqualToPoint(oldPoint, CGPointZero)) {
        oldPoint = point;
        return;
    }
    
    if (CGPointEqualToPoint(oldPoint, point))
        return;
    
    BOOL directionHorisontal = ABS(((oldPoint.x - point.x)/(oldPoint.y - point.y)))>1;
    oldPoint = point;
    
    if (directionHorisontal != _directionHorisontal) {
        _directionHorisontal = directionHorisontal;
        _startPoint = point;
        
        if ([_delegate respondsToSelector:@selector(tapViewDidFinishedRotating:)])
            [_delegate tapViewDidFinishedRotating:self];
        
        if ([_delegate respondsToSelector:@selector(tapViewWillStartRotating:)])
            [_delegate tapViewWillStartRotating:self];
        
        return;
    }
    
    BOOL clockwise = NO;
    
    if (_directionHorisontal) {
        CGFloat centerY = self.center.y;
        clockwise = (_startPoint.y<centerY && point.y<centerY && point.x>_startPoint.x) || (_startPoint.y>centerY && point.y > centerY && point.x<_startPoint.x);
    }
    else {
        CGFloat centerX = self.center.x;
        clockwise = (_startPoint.x<centerX && point.x<centerX && point.y<_startPoint.y) || (_startPoint.x>centerX && point.x > centerX && point.y>_startPoint.y);
    }
    
    _rotating = clockwise ? RotatingClockwise : RotatingCounterClockwise;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
