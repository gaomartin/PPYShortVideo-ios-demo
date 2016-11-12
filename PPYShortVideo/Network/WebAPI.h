//
//  WebAPI.h
//  PPYShortVideo
//
//  Created by admin on 2016/11/9.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface WebAPI : NSObject

+(void)fetchShortVideoListSuccess:(void (^) (NSDictionary *))successBlock
                          Failured:(void (^) (NSError *))failuredBlock;

+(void)uploadShortVideo:(NSString *)url Progress:(void (^) (NSProgress *))progressBlock
                                        Success:(void (^) (NSDictionary *))successBlock
                                        Failured:(void (^) (NSError *))failuredBlock;
@end
