//
//  WebAPI.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "WebAPI.h"
#import "AFNetworking.h"

#define kURLShortVideo_Upload    @"http://115.231.44.26:8081/video/upload"
#define kURLShortVideo_Download  @"http://115.231.44.26:8081/video/download"
#define kURLShortVideo_List      @"http://115.231.44.26:8081/video/list"

@implementation WebAPI

+(void)fetchShortVideoListSuccess:(void (^) (NSDictionary *))successBlock
                         Failured:(void (^) (NSError *))failuredBlock
{

    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    
    httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    httpManager.requestSerializer.timeoutInterval = 5;
    
    AFJSONResponseSerializer *jsonSerizlizer = [AFJSONResponseSerializer serializer];
    jsonSerizlizer.removesKeysWithNullValues = YES;
    httpManager.responseSerializer = jsonSerizlizer;
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [httpManager GET:kURLShortVideo_List parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        successBlock(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuredBlock(error);
    }];
}

static NSURLSessionUploadTask *curUploadTask;

+(void)uploadShortVideo:(NSString *)url Progress:(void (^) (NSProgress *))progressBlock
                                        Success:(void (^) (NSDictionary *))successBlock
                                        Failured:(void (^) (NSError *))failuredBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:kURLShortVideo_Upload]];
    [request setHTTPMethod:@"POST"];
    NSData *videoData = [NSData dataWithContentsOfFile:url];
    [request setHTTPBody:videoData];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    AFJSONResponseSerializer *jsonSerizlizer = [AFJSONResponseSerializer serializer];
//    jsonSerizlizer.removesKeysWithNullValues = YES;
//    manager.responseSerializer = jsonSerizlizer;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:videoData progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
          if(error) {
              failuredBlock(error);
          } else {
              NSDictionary *dic = (NSDictionary *)responseObject;
              successBlock(dic);
          }
    }];
    
    curUploadTask = uploadTask;
    NSLog(@"uploadTask=%@", uploadTask);
    [uploadTask resume];
}

+ (void)uploadCancel
{
    [curUploadTask cancel];
}

@end
