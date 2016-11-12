//
//  PlayerView.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/8.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "PlayerView.h"
#import "Masonry.h"


@interface PlayerView ()<PPYPlayEngineDelegate>
@property (strong, nonatomic) UIView *displayView;
@property (strong, nonatomic) UIView *playControlView;
@property (strong, nonatomic) UIButton *btnStartOrPause;

@property (nonatomic,assign) BOOL isPlaying;
@end

#define JPlayControllerLog(format, ...) NSLog((@"PlayerController_"format), ##__VA_ARGS__)

@implementation PlayerView

+(instancetype)playerViewWithURL:(NSString *)url andSourceType:(PPYSourceType)sourceType{
    PlayerView *__instance = [[self alloc]init];
    __instance.playerURL = url;
    __instance.sourceType = PPYSourceType_VOD;
    return __instance;
}
-(void)initialize{
    _displayView = [UIView new];
    [self addSubview:_displayView];
    
    _btnStartOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnStartOrPause setImage:[UIImage imageNamed:@"bofang-.png"] forState:UIControlStateNormal];
    [_btnStartOrPause addTarget:self action:@selector(onPressBtnStartOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnStartOrPause];
    
    [_displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(self);
    }];
    
    [_btnStartOrPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(self);
    }];
    
    [PPYPlayEngine shareInstance].delegate = self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        [self initialize];
        
        //todo
//        _playControlView = [UIView new];
//        [self addSubview:_playControlView];
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self initialize];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [PPYPlayEngine shareInstance].previewRect = self.displayView.frame;
    [super layoutSubviews];
}

-(void)dealloc{
    [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:YES];
    NSLog(@"PlayerView delloc!");
}

-(void)setPlayerURL:(NSString *)playerURL{
    _playerURL = playerURL;
    
    if(self.needPlayWhenAppear){
        if(!self.isPlaying){
            [self startPlay];
        }
    }
}

-(void)startPlay{
    [[PPYPlayEngine shareInstance] startPlayFromURL:self.playerURL WithType:PPYSourceType_VOD];
    [self.btnStartOrPause mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(-1000, -1000));
    }];
    [self layoutIfNeeded];
}

-(void)onPressBtnStartOrPause:(UIButton *)sender{
    [self startPlay];
}

#pragma mark --<PPYPlayEngineDelegate>

-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error{
    switch (error) {
        case PPYPlayEngineError_InvalidSourceURL:
            break;
        case PPYPlayEngineError_ConnectFailed:
            break;
        case PPYPlayEngineError_TransferFailed:
            break;
        case PPYPlayEngineError_FatalError:
            break;
    }
    JPlayControllerLog(@"error = %d",error);
}

-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value{
    switch (type) {
        case PPYPlayEngineInfo_BufferingDuration:
            break;
        case PPYPlayEngineInfo_RealBirate:
            break;
        case PPYPlayEngineInfo_RealFPS:
 
        case PPYPlayEngineInfo_BufferingUpdatePercent:
            break;
        case PPYPlayEngineInfo_Duration:
           
            break;
    }
    JPlayControllerLog(@"type = %d,value = %d",type,value);
}

-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state{

    switch (state) {
        case PPYPlayEngineStatus_StartCaching:
  
            break;
        case PPYPlayEngineStatus_EndCaching:
          
            break;
        case PPYPlayEngineStatus_FisrtKeyFrameComing:
            [[PPYPlayEngine shareInstance] presentPreviewOnView:_displayView];
            self.isPlaying = YES;
            break;
        case PPYPlayEngineStatus_RenderingStart:
            break;
        case PPYPlayEngineStatus_ReceiveEOF:
        {
            [self.btnStartOrPause mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
            [self layoutIfNeeded];
            self.isPlaying = NO;
        }
            break;
        case PPYPlayEngineStatus_SeekComplete:
            break;
    }
    JPlayControllerLog(@"state = %lu",(unsigned long)state);
}

-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height{
    JPlayControllerLog(@"width = %d,height = %d",width,height);
}


@end
