//
//  BZEditVideoInfo.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/27.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "BZEditVideoInfo.h"

@implementation BZEditVideoInfo

+ (instancetype)shareInstance
{
    static BZEditVideoInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BZEditVideoInfo alloc]init];
    });
    return instance;
}


- (instancetype)init
{
    if(self = [super init]){
        self.editVideoArry = [NSMutableArray array];
        self.localEditVideoArry = [NSMutableArray array];
        self.editVideoType = BZEditVideoType_None;
    }
    
    return self;
}

- (void)clearCache
{
    self.editVideoType = BZEditVideoType_None;
    self.editVideoArry = nil;
    self.localEditVideoArry = nil;
    self.mediaProduct = nil;
}

@end
