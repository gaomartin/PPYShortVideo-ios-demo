//
//  NSString+time.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/23.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (time)

//毫秒转换为时间, 如05:30
+ (NSString*)timeformatFromSeconds:(NSInteger)seconds;


@end
