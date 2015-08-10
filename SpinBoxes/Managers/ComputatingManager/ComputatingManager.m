//
//  CalculationManager.m
//  SpinBoxes
//
//  Created by vaskov on 17.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "ComputatingManager.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0f / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0f * M_PI)
#define LENGHT_TO_CELLS_FROM_EDGE 10.0f

static ConfigurationBox staticConfiguration;

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
    
    view.center = view.superview.center;
    
    ConfigurationBox configuration;
    configuration.boxSize    = CGSizeMake(widthBox, heightBox);
    configuration.centerXMin = LENGHT_TO_CELLS_FROM_EDGE + widthBox/2;
    configuration.centerXMax = view.width - LENGHT_TO_CELLS_FROM_EDGE - widthBox/2;
    configuration.centerYMin = LENGHT_TO_CELLS_FROM_EDGE + heightBox/2;
    configuration.centerYMax = view.height - LENGHT_TO_CELLS_FROM_EDGE - heightBox/2;
    configuration.radiusX = (configuration.centerXMax - configuration.centerXMin)/2;
    configuration.radiusY = (configuration.centerYMax - configuration.centerYMin)/2;
    configuration.center = CGPointMake(view.width/2, view.height/2);
    
    staticConfiguration = configuration;
    
    return staticConfiguration;
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
    CGPoint center = staticConfiguration.center;
    
    return sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2));
}

- (CGPoint)centerBoxViewWithAlpha:(CGFloat)alpha
{
    alpha = [self resetAngle:alpha];
    
    CGFloat centerBoxViewX = -1, centerBoxViewY = -1;
    ConfigurationBox c = staticConfiguration;
    
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

- (CGFloat)alphaInDegreesForBoxWithCenter:(CGPoint)center
{
    ConfigurationBox c = staticConfiguration;
    
    CGFloat y = center.y - c.center.y;
    CGFloat x = center.x - c.center.x;
    
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
    
    return RADIANS_TO_DEGREES(radian);
}

- (CGPoint)finishCenterBoxViewWithAlpha:(CGFloat)alpha
{
    static CGFloat currentAngle = 0, oldAngle = 0;
    BOOL isClockwise = YES;
    NSInteger index = 0;
    
    currentAngle = [self resetAngle:alpha];
    
    if (currentAngle > 1 && currentAngle < 359 && currentAngle != oldAngle)
        isClockwise = currentAngle > oldAngle;
    
    oldAngle = currentAngle;
    
    while (currentAngle > 0) {
        currentAngle -= 45;
        index++;
    }
    
    NSArray *angles = @[@(0), @(45), @(90), @(135), @(180), @(225), @(270), @(315)];
    
    if (isClockwise) {
        if (index > (angles.count - 1))
            index = 0;
    }
    else {
        if (--index < 0) {
            index = (angles.count - 1);
        }
    }
    
    return [self centerBoxViewWithAlpha:[angles[index] floatValue]];
}

@end
