//
//  PlayListHelper.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "PlayListHelper.h"
#import "WebAPI.h"
#import "NSObject+YYModel.h"


@implementation PlayListHelper

-(void)fetchVODList{
    [WebAPI fetchShortVideoListSuccess:^(NSDictionary *dic) {
        ShortVideoListModel *videoList = [ShortVideoListModel yy_modelWithDictionary:dic];
        if(videoList.err == 0){
            [self.delegate didFetchVODListSuccessed:videoList.data];
        }else{
            [self.delegate didFetchVODListFailured:WebAPI_ReturnError Code:videoList.err Info:videoList.msg];
        }
    } Failured:^(NSError *err) {
        [self.delegate didFetchVODListFailured:AFNetworking_Error Code:err.code Info:err.debugDescription];
    }];
}

-(void)uploadShortVideo:(NSString *)url Progress:(void (^) (NSProgress *))progressBlock
                Success:(void (^) (void))successBlock
               Failured:(void (^) (NetworkErrorType,int,NSString *))failuredBlock
{
    [WebAPI uploadShortVideo:url Progress:progressBlock Success:^(NSDictionary *dic) {
        GenerateResponseModel *model = [GenerateResponseModel yy_modelWithDictionary:dic];
        if(model.err == 0){
            successBlock();
        }else{
            failuredBlock(WebAPI_ReturnError,model.err,model.msg);
        }
    } Failured:^(NSError *err) {
        failuredBlock(AFNetworking_Error,err.code,err.debugDescription);
    }];
}

-(void)downLoadWebImage:(NSString *)url onQueueAsync:(dispatch_queue_t)queue completionHandler:(void(^)(NSData *data))handle{
    
    dispatch_async(queue, ^{
        NSError *error=nil;
        NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        NSData *imgData=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            handle(imgData);
        });
    });
}
@end
