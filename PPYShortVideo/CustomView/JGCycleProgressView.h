//
//  JGCycleProgressView.h
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGCycleProgressView : UIView
@property (nonatomic, strong) UILabel *label;
- (void)drawProgress:(CGFloat )progress;
@end
