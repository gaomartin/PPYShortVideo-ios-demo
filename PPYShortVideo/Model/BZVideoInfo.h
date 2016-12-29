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
@property (nonatomic, assign) NSTimeInterval startPos;
@property (nonatomic, assign) NSTimeInterval endPos;
@property (nonatomic, assign) NSTimeInterval total;
@property (nonatomic, assign) NSTimeInterval weight; //0.0 - 1.0
@property (nonatomic, assign) BOOL isSelected;

@end
