//
//  DynamicItem.h
//  SpinBoxes
//
//  Created by vaskov on 10.08.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DynamicItemDelegate;


@interface DynamicItem : UIView
@property (nonatomic, weak) UIDynamicItemBehavior *linearVelocityBehavior;
@property (nonatomic, weak) id<DynamicItemDelegate> delegate;
- (void)addDynamicsWithView:(UIView *)view;
- (void)removeAllBehaviors;
- (void)addLinearVelocity:(CGPoint)velocity actionDynamicItemBehavior:(void(^)())action;
@end


@protocol DynamicItemDelegate <NSObject>
- (void)animatorDidPauseWithDynamicItem:(DynamicItem *)item;
@end
