//
//  WebAPIResponseModels.h
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GenerateResponseModel:NSObject
@property (assign, nonatomic) NSInteger err;
@property (copy, nonatomic)   NSString *msg;
@end

@interface ShortVideoListModel : NSObject
@property (assign, nonatomic) NSInteger err;
@property (copy, nonatomic)   NSString *msg;
@property (strong, nonatomic) NSArray *data;    //ShortVideoModel
@property (assign, nonatomic) NSInteger totalnum;
@end

@interface ShortVideoModel : NSObject
@property (copy, nonatomic) NSString *vid;
@property (copy, nonatomic) NSString *video_url;
@property (copy, nonatomic) NSString *create_time;
@property (copy, nonatomic) NSString *create_time_text;
@property (copy, nonatomic) NSString *screen_url;
@end
