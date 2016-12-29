//
//  PlayerView.h
//  PPYShortVideo
//
//  Created by admin on 2016/11/8.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerView : UIView

@property (copy, nonatomic) NSString *playerURL;
@property (assign, nonatomic) PPYSourceType sourceType;
@property (assign, nonatomic) BOOL needPlayWhenAppear;

//剪切页面的效果参数
@property (assign, nonatomic) BOOL needPrepareToPlay;
@property (assign, nonatomic) NSTimeInterval defaultSeekTime;

- (void)seekToPostion:(NSTimeInterval)position;
- (void)resume;
- (void)pause;
- (void)stop;

@end
