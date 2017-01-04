//
//  BZEditVideoInfo.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/27.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, BZEditVideoType) {
    BZEditVideoType_None,
    BZEditVideoType_FromRecordView,
    BZEditVideoType_FromAddLocal,
};

@interface BZEditVideoInfo : NSObject

@property (nonatomic, assign) BZEditVideoType editVideoType;
@property (nonatomic, strong) NSMutableArray *editVideoArry;
@property (nonatomic, strong) NSMutableArray *localEditVideoArry;
@property (nonatomic, strong) PPYMediaProduct* mediaProduct;

+ (instancetype)shareInstance;

- (void)clearCache;

@end
