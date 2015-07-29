//
//  CalculationManager.h
//  SpinBoxes
//
//  Created by vaskov on 17.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct
{
    CGSize boxSize;
    
    CGFloat centerXMin;
    CGFloat centerXMax;
    CGFloat centerYMin;
    CGFloat centerYMax;
    
    CGFloat radiusX;
    CGFloat radiusY;
    CGPoint center;
}ConfigurationBox;


@interface ComputatingManager : NSObject
+ (ConfigurationBox)setConfigurationWithView:(UIView *)view;
+ (CGFloat)resetAngle:(CGFloat)angle;

+ (CGPoint)centerBoxViewWithAlpha:(CGFloat)alpha;
+ (CGFloat)lenghtWithAlpha:(CGFloat)alpha;
+ (CGFloat)alphaInDegreesForBoxWithCenter:(CGPoint)center;

+ (CGPoint)finishCenterBoxViewWithAlpha:(CGFloat)alpha;

@end

