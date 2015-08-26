//
//  SpinTheBoxesView.h
//  SpinBoxes
//
//  Created by vaskov on 10.05.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoxView;
@protocol SpinTheBoxesViewDelegate;


@interface SpinTheBoxesView : UIView
@property (nonatomic, weak) id<SpinTheBoxesViewDelegate> delegate;
@property (nonatomic, assign) CGFloat value;
@end


@protocol SpinTheBoxesViewDelegate <NSObject>
- (void)spinTheBoxesView:(SpinTheBoxesView *)view tapOnView:(BoxView *)boxView;
- (void)spinTheBoxesView:(SpinTheBoxesView *)view longPressBeginOnView:(BoxView *)boxView;
- (void)spinTheBoxesView:(SpinTheBoxesView *)view longPressEndedOnView:(BoxView *)boxView;
@end