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

- (void)stop;

@end
