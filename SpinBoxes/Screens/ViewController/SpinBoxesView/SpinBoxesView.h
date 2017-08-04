//
//  SpinBoxesView.h
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoxView;
@protocol SpinBoxesViewDelegate;


@interface SpinBoxesView : UIView
@property (nonatomic, weak) id<SpinBoxesViewDelegate> delegate;
@end


@protocol SpinBoxesViewDelegate <NSObject>
- (void)spinBoxesView:(SpinBoxesView *)view tapOnView:(BoxView *)boxView;
- (void)spinBoxesView:(SpinBoxesView *)view longPressBeginOnView:(BoxView *)boxView;
- (void)spinBoxesView:(SpinBoxesView *)view longPressEndedOnView:(BoxView *)boxView;
@end
