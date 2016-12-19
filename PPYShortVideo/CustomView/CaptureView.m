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

@end

@implementation CaptureView


-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        PPYAudioConfiguration *audioConfigurate = [PPYAudioConfiguration defalutAudioConfiguration];
        PPYVideoConfiguration *videoConfigurate = [PPYVideoConfiguration defalutVideoConfiguration];
        
        self.pushEngine = [[PPYPushEngine alloc]initWithAudioConfiguration:audioConfigurate andVideoConfiguration:videoConfigurate];
        
        self.pushEngine.preview = self;
        self.pushEngine.running = YES;

    }
    return self;
}

@end
