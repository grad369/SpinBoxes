//
//  DynamicItem.m
//  SpinBoxes
//
//  Created by vaskov on 10.08.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import "DynamicItem.h"
#import "UIView+Helpers.h"
#import "ComputatingManager.h"

@interface DynamicItem () <UIDynamicAnimatorDelegate>
@property (nonatomic, strong) UIDynamicAnimator *animator;
@end

@implementation DynamicItem

- (void)addDynamicsWithView:(UIView *)view
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:view];
    self.animator.delegate = self;
    [self setAttachmentBehavior];
}

- (void)removeAllBehaviors
{
    [_animator removeAllBehaviors];
    [self setAttachmentBehavior];
}

- (void)addLinearVelocity:(CGPoint)velocity actionDynamicItemBehavior:(void(^)())action
{
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    [item addLinearVelocity:velocity forItem:self];
    item.density = 500;
    item.friction = 500;
    item.action = action;
    
    [_animator updateItemUsingCurrentState:self];
    [_animator addBehavior:item];
    self.linearVelocityBehavior = item;
}

#pragma mark - |UIDynamicAnimatorDelegate|

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator
{
    NSLog(@"===%@1", animator);
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
    if (_delegate != nil)
        [_delegate animatorDidPauseWithDynamicItem:self];
    
    NSLog(@"===%@2", animator);
}

#pragma mark - Privates

- (void)setAttachmentBehavior
{
    CGPoint attachmentPoint = CGPointMake(_animator.referenceView.width/2, _animator.referenceView.height/2);
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    item.allowsRotation = NO;
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:attachmentPoint];
    attachmentBehavior.frequency = 10;
    attachmentBehavior.damping = 2.5;
    [attachmentBehavior addChildBehavior:item];
    
    [_animator addBehavior:attachmentBehavior];
}

@end
