//
//  WebAPIResponseModels.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "WebAPIResponseModels.h"
#import "NSObject+YYModel.h"

@implementation GenerateResponseModel

@end


@implementation ShortVideoListModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    return @{
             @"data" : [ShortVideoModel class]
             };
}
@end

@implementation ShortVideoModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"VID" : @"id",
             };
}
@end
