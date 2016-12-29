//
//  BZEditVideoInfo.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/27.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BZEditVideoInfo : NSObject

@property (nonatomic, strong) NSMutableArray *editVideoArry;
@property (nonatomic, strong) PPYMediaProduct* mediaProduct;

+ (instancetype)shareInstance;

@end
