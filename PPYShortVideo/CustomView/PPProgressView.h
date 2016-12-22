//
//  PPProgressView.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/14.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PPProgressViewStatus){
    PPProgressViewStatus_wait,           //进度条停止等待等初始状态
    PPProgressViewStatus_refreshing,     //进度条不断刷新的状态
    PPProgressViewStatus_Cancel,         //进度条等待取消的状态
    PPProgressViewStatus_Delete,         //删除最后一段
};


@interface PPProgressModel : NSObject

@property (nonatomic ,strong) UIView *progressView;
@property (nonatomic ,assign) float progressTime;

@end

@interface PPProgressView : UIView

- (void)refreshProgressWithValue:(CGFloat)value;
- (void)refreshProgressStatus:(PPProgressViewStatus)status;
- (void)deleteLastProgress;
- (void)clear;

@end
