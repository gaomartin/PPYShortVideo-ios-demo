//
//  CaptureView.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/7.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "CaptureView.h"

@interface CaptureView ()
@property (strong, nonatomic) PPYPushEngine *pushEngine;
@property (copy, nonatomic) NSString *recordPath;
@end

@implementation CaptureView



-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        self.recordPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [self.recordPath stringByAppendingPathComponent:@"defalut"];
        
        PPYAudioConfiguration *audioConfigurate = [PPYAudioConfiguration defalutAudioConfiguration];
        PPYVideoConfiguration *videoConfigurate = [PPYVideoConfiguration defalutVideoConfiguration];
        self.pushEngine = [[PPYPushEngine alloc]initWithAudioConfiguration:audioConfigurate andVideoConfiguration:videoConfigurate pushRTMPAddress:self.recordPath];
        
        self.pushEngine.preview = self;
        self.pushEngine.running = YES;

    }
    return self;
}

@end
