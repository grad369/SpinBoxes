//
//  CalculationManager.m
//  SpinBoxes
//
//  Created by vaskov on 17.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "ComputatingManager.h"
#import "MTKObserving.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0f / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0f * M_PI)
#define LENGHT_TO_CELLS_FROM_EDGE 10.0f

@interface ComputatingManager ()
@end

@implementation ComputatingManager

+ (instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

- (instancetype) initUniqueInstance {
    self = [super init];
    if (self)
    {
    }
    return self;
}

#pragma mark - Publics

- (ConfigurationBox)setConfigurationWithView:(UIView *)view
{
    CGFloat widthBetweenCells = LENGHT_TO_CELLS_FROM_EDGE, heightBetweenCells = LENGHT_TO_CELLS_FROM_EDGE;
    CGFloat widthBox = (view.width - 2 * widthBetweenCells - 2 * LENGHT_TO_CELLS_FROM_EDGE)/3;
    CGFloat heightBox = (view.height - 2 * heightBetweenCells - 2 * LENGHT_TO_CELLS_FROM_EDGE)/3;
    
    if (widthBox/RATIO < heightBox) {
        heightBox = widthBox/RATIO;
        heightBetweenCells = (view.height - 3 * heightBox - 2 * LENGHT_TO_CELLS_FROM_EDGE)/2;
    }
    else {
        widthBox = heightBox * RATIO;
        widthBetweenCells = (view.width - 3 * widthBox- 2 * LENGHT_TO_CELLS_FROM_EDGE)/2;
    }
    
    ConfigurationBox configuration;
    configuration.boxSize    = CGSizeMake(widthBox, heightBox);
    configuration.centerXMin = LENGHT_TO_CELLS_FROM_EDGE + widthBox/2;
    configuration.centerXMax = view.width - LENGHT_TO_CELLS_FROM_EDGE - widthBox/2;
    configuration.centerYMin = LENGHT_TO_CELLS_FROM_EDGE + heightBox/2;
    configuration.centerYMax = view.height - LENGHT_TO_CELLS_FROM_EDGE - heightBox/2;
    configuration.radiusX = (configuration.centerXMax - configuration.centerXMin)/2;
    configuration.radiusY = (configuration.centerYMax - configuration.centerYMin)/2;
    configuration.center = CGPointMake(view.width/2, view.height/2);
    
    _configurationBox = configuration;
    
    return _configurationBox;
}

- (CGFloat)resetAngle:(CGFloat)angle
{
    CGFloat currentAngle = angle;
    
    if (currentAngle < 0.0f){
        while(currentAngle < 0.0f){
            currentAngle += 360.0f;
        };
    }
    else {
        while(currentAngle >= 360.0f){
            currentAngle -= 360.0f;
        };
    }
    
    return currentAngle;
}

- (CGFloat)lenghtWithAlpha:(CGFloat)alpha
{
    CGPoint point = [self centerBoxViewWithAlpha:alpha];
    CGPoint center = _configurationBox.center;
    
    return sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2));
}

- (CGPoint)centerBoxViewWithAlpha:(CGFloat)alpha
{
    alpha = [self resetAngle:alpha];
    
    CGFloat centerBoxViewX = -1, centerBoxViewY = -1;
    ConfigurationBox c = _configurationBox;
    
    if (alpha == 0) {
        return CGPointMake(c.center.x, c.centerYMin);
    }
    else if (alpha < 45){
        centerBoxViewY = c.centerYMin;
        centerBoxViewX = c.center.x + c.radiusX * tan(DEGREES_TO_RADIANS(alpha));
    }
    else if (alpha == 45){
        return CGPointMake(c.centerXMax, c.centerYMin);
    }
    else if (alpha < 90){
        centerBoxViewX = c.centerXMax;
        centerBoxViewY = c.center.y - c.radiusY * tan(DEGREES_TO_RADIANS(90-alpha));
    }
    else if (alpha == 90){
        return CGPointMake(c.centerXMax, c.center.y);
    }
    else if (alpha < 135){
        centerBoxViewX = c.centerXMax;
        centerBoxViewY = c.center.y + c.radiusY * tan(DEGREES_TO_RADIANS(alpha-90));
    }
    else if (alpha == 135){
        return CGPointMake(c.centerXMax, c.centerYMax);
    }
    else if (alpha < 180){
        centerBoxViewY = c.centerYMax;
        centerBoxViewX = c.center.x + c.radiusX * tan(DEGREES_TO_RADIANS(180-alpha));
    }
    else if (alpha == 180){
        return CGPointMake(c.center.x, c.centerYMax);
    }
    else if (alpha < 225){
        centerBoxViewY = c.centerYMax;
        centerBoxViewX = c.center.x - c.radiusX * tan(DEGREES_TO_RADIANS(alpha-180));
    }
    else if (alpha == 225){
        return CGPointMake(c.centerXMin, c.centerYMax);
    }
    else if (alpha < 270){
        centerBoxViewX = c.centerXMin;
        centerBoxViewY = c.center.y + c.radiusY * tan(DEGREES_TO_RADIANS(270-alpha));
    }
    else if (alpha == 270){
        return CGPointMake(c.centerXMin, c.center.y);
    }
    else if (alpha < 315){
        centerBoxViewX = c.centerXMin;
        centerBoxViewY = c.center.y - c.radiusY * tan(DEGREES_TO_RADIANS(alpha-270));
    }
    else if (alpha == 315){
        return CGPointMake(c.centerXMin, c.centerYMin);
    }
    else if (alpha < 360){
        centerBoxViewY = c.centerYMin;
        centerBoxViewX = c.center.x - c.radiusX * tan(DEGREES_TO_RADIANS(360-alpha));
    }
    else{
        NSAssert(NO, @"  ERROR:  centerBoxViewWithAlpha");
    }
    
    return CGPointMake(centerBoxViewX, centerBoxViewY);
}

- (CGFloat)alphaInDegreesForBoxWithPoint:(CGPoint)point
{
    CGFloat y = _configurationBox.center.y - point.y;
    CGFloat x = _configurationBox.center.x - point.x;
    
    CGFloat radian = 0;
    
    if (x < 0)
    {
        radian = atan(y/x) + M_PI;
    }
    else if (x == 0)
    {
        if (y < 0)
            radian = 3 * M_PI_2;
        else
            radian = M_PI_2;
    }
    else
    {
        if (y < 0)
            radian = atan(y/x) + 2 * M_PI;
        else
            radian = atan(y/x);
    }
    
    return [self resetAngle:(RADIANS_TO_DEGREES(radian) - 90)];
}

- (BOOL)isClockwiseWithAlpha:(CGFloat)alpha
{
    static CGFloat currentAngle = 0, oldAngle = 0;
    static BOOL isClockwise = YES;
    
    currentAngle = [self resetAngle:alpha];
    
    if (currentAngle > 1 && currentAngle < 359 && currentAngle != oldAngle)
        isClockwise = currentAngle > oldAngle;
    
    oldAngle = currentAngle;
    
    return isClockwise;
}

- (CGPoint)finishCenterBoxViewWithAlpha:(CGFloat)alpha clockwise:(BOOL)isClockwise
{
    CGFloat currentAngle = [self resetAngle:alpha];
    
    NSInteger index = 0;
    
    while (currentAngle > 0) {
        currentAngle -= 45;
        index++;
    }
    
    NSArray *angles = @[@(0), @(45), @(90), @(135), @(180), @(225), @(270), @(315)];
    
    if (isClockwise) {
        index += 3;
        
        if (index > (angles.count - 1))
            index -= angles.count;
    }
    else {
        index -= 4;
        if (index < 0) {
            index += angles.count;
        }
    }
    
    return [self centerBoxViewWithAlpha:[angles[index] floatValue]];
}

- (CGFloat)nearestAngleCenterBoxViewWithAlpha:(CGFloat)alpha
{
    CGFloat currentAngle = [self resetAngle:alpha];
    CGFloat minDeltaAngle = CGFLOAT_MAX;
    NSInteger index = 0;
    
    NSArray *angles = @[@(0), @(45), @(90), @(135), @(180), @(225), @(270), @(315)];
    
    for (NSInteger i = 0; i < angles.count; i++) {
        CGFloat angle = [angles[i] floatValue];
        
        if (ABS(currentAngle - angle) < minDeltaAngle) {
            minDeltaAngle = ABS(currentAngle - angle);
            index = i;
        }
    }
    
   return [angles[index] floatValue];
}

- (CGFloat)nearestAngleCenterBoxViewWithAlpha:(CGFloat)alpha clockwise:(BOOL)clockwise
{
    CGFloat currentAngle = [self resetAngle:alpha];
    NSInteger currentIndex = 0;
    
    NSArray *angles = @[@(0), @(45), @(90), @(135), @(180), @(225), @(270), @(315)];
    
    while (currentAngle > 0) {
        currentAngle -= 45;
        currentIndex++;
    }
    
    if (!clockwise)
        currentIndex--;
    
    if (currentIndex >= angles.count)
        currentIndex -= angles.count;
    
    if (currentIndex < 0)
        currentIndex += angles.count;
    
    return [angles[currentIndex] floatValue];
}

- (CGFloat)alphaInDegreesWithStartAlpha:(CGFloat)startAlpha
                              clockwise:(BOOL)clockwise
                                  steps:(NSUInteger)steps
                                   step:(NSUInteger)step
{
    static CGFloat deltaAlpha = 0;
    
    if (step == 0)
    {
        CGPoint finishCenterBoxView = [self finishCenterBoxViewWithAlpha:startAlpha clockwise:clockwise];
        CGFloat finishAlpha = [self alphaInDegreesForBoxWithPoint:finishCenterBoxView];
        
        if ((startAlpha < finishAlpha && clockwise) || (startAlpha > finishAlpha && !clockwise)) {
            deltaAlpha = (finishAlpha - startAlpha) / steps;
        }
        else {
            CGFloat delta = clockwise ? 360 : -360;
            deltaAlpha = (finishAlpha - startAlpha + delta) / steps;
        }
    }
    
    return [self resetAngle:(startAlpha + deltaAlpha * step)];
}

@end
