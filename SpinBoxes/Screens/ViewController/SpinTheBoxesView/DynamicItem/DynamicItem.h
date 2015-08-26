//
//  DynamicItem.h
//  SpinBoxes
//
//  Created by vaskov on 10.08.15.
//  Copyright (c) 2015 vaskov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicItem : UIView
@property (nonatomic, weak) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, weak) UIDynamicItemBehavior *linearVelocityBehavior;
@property (nonatomic, weak) UISnapBehavior *snapBehavior;
@end
