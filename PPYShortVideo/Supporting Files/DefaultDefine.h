//
//  DefaultDefine.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/28.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#ifndef DefaultDefine_h
#define DefaultDefine_h

//获取屏幕 宽度、高度
#define KMainScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#define KMainScreenHeight   ([UIScreen mainScreen].bounds.size.height)

//视频添加
#define kAddVideoSuccessNotificatin @"AddVideoSuccessNotificatin"

// caches路径
#define KCachesPath  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kOffScreenNumber 1000

#endif /* DefaultDefine_h */
