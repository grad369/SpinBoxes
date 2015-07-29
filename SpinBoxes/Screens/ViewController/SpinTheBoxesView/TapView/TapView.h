//
//  TapView.h
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapViewDelegate;

@interface TapView : UIView
@property (nonatomic, weak) id<TapViewDelegate> delegate;
@end



@protocol TapViewDelegate <NSObject>
@optional
- (void)tapViewWillStartRotating:(TapView *)tapView;
- (void)tapViewRotating:(TapView *)tapView deltaAlpha:(CGFloat)alpha clockwise:(BOOL)theClockwise;
- (void)tapViewWillStartDecelerating:(TapView *)tapView velocity:(CGPoint)point clockwise:(BOOL)isClockwise;
- (void)tapViewDidFinishedRotating:(TapView *)tapView;

- (void)tapViewWithTapRecognizer:(TapView *)tapView point:(CGPoint)thePoint;
- (void)tapViewWithLongTapRecognizer:(TapView *)tapView point:(CGPoint)thePoint;
- (void)tapViewWithLongTapFinishedRecognizer:(TapView *)tapView point:(CGPoint)thePoint;
@end
