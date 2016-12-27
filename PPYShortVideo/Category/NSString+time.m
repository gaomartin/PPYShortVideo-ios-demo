//
//  NSString+time.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/23.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "NSString+time.h"

@implementation NSString (time)

+ (NSString*)timeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02zd",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02zd",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02zd",seconds%60];
    //format of time
    NSString *format_time = @"00:00";
    
    if ([str_hour integerValue] > 0) {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    
    return format_time;
}

@end
