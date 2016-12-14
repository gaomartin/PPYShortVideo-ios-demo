//
//  UIColor+BZHex.h
//  CargoLogistics
//
//  Created by bobzhang on 16/4/6.
//  Copyright © 2016年 张博bobzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BZHex)


+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

//ios不识别16进制的表示法，需要转化成rgb表示法
+ (UIColor *)hexStringToColor:(NSString *)stringToConvert;

@end
