//
//  ContainerBoxView.h
//  SpinTheBoxes
//
//  Created by vaskov on 08.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString const *BoxViewChangeAlphaNotification;

@protocol BoxViewDelegate;


@interface BoxView : UIView
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) id<BoxViewDelegate> delegate;
@end


@protocol BoxViewDelegate <NSObject>
@required
- (void)boxView:(BoxView *)view swipeWithVelocity:(CGPoint)velocity;
- (void)touchesBeginOnBoxView:(BoxView *)view tapPointInSuperview:(CGPoint)point;
- (void)touchesMovedOnBoxView:(BoxView *)view tapPointInSuperview:(CGPoint)point;
- (void)touchesEndedOnBoxView:(BoxView *)view;
- (void)longPressBeginOnBoxView:(BoxView *)view;
- (void)longPressEndedOnBoxView:(BoxView *)view;
@end