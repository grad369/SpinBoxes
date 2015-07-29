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
@property (nonatomic, assign) CGFloat currentAngle;
//@property (nonatomic, assign) BOOL activeBox;
@property (nonatomic, assign) id<BoxViewDelegate> delegate;

//@property (nonatomic, weak) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@end


@protocol BoxViewDelegate <NSObject>
- (void)boxView:(BoxView *)view swipeWithVelocity:(CGPoint)velocity;
@end