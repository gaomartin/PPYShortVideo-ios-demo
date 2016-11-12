//
//  PlayListHelper.h
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebAPIResponseModels.h"

typedef NS_ENUM(int, NetworkErrorType){
    WebAPI_ReturnError,
    AFNetworking_Error,
};

@protocol PlayListHelperDelegate <NSObject>
-(void)didFetchVODListSuccessed:(NSArray *)list;
-(void)didFetchVODListFailured:(NetworkErrorType)type Code:(int)errorCode Info:(NSString *)errInfo;
@end

@interface PlayListHelper : NSObject

@property (weak, nonatomic) id<PlayListHelperDelegate> delegate;

-(void)fetchVODList;
-(void)uploadShortVideo:(NSString *)url Progress:(void (^) (NSProgress *))progressBlock
                Success:(void (^) (void))successBlock
               Failured:(void (^) (NetworkErrorType,int,NSString *))failuredBlock;

-(void)downLoadWebImage:(NSString *)url onQueueAsync:(dispatch_queue_t)queue completionHandler:(void(^)(NSData *data))handle;
@end
