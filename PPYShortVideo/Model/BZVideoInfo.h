//
//  BZVideoInfo.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/20.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BZVideoInfo : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic) NSTimeInterval startPos;
@property (nonatomic) NSTimeInterval endPos;
@property (nonatomic) NSTimeInterval weight; //0.0 - 1.0
@property (nonatomic) BOOL isSelected;

@end
