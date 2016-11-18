//
//  PlayerView.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/8.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "PlayerView.h"
#import "Masonry.h"
#import "JGPlayerControlPanel.h"
#import "MBProgressHUD.h"

#define kOffScreenNumber 1000

@interface PlayerView ()<PPYPlayEngineDelegate,JGPlayControlPanelDelegate>
@property (strong, nonatomic) UIView *displayView;
@property (strong, nonatomic) UIButton *btnStartOrPause;
@property (strong, nonatomic) UIImageView *previewImage;

@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,copy)   NSString *cachImagePath;

@property (nonatomic, strong) JGPlayerControlPanel *controlPanel;
@property (nonatomic, strong) NSTimer *timer;
@end

#define JPlayControllerLog(format, ...) NSLog((@"PlayerController_"format), ##__VA_ARGS__)

@implementation PlayerView

+(instancetype)playerViewWithURL:(NSString *)url andSourceType:(PPYSourceType)sourceType{
    PlayerView *__instance = [[self alloc]init];
    __instance.playerURL = url;
    __instance.sourceType = sourceType;
    return __instance;
}

-(void)initialize{
    _displayView = [UIView new];
    [self addSubview:_displayView];
    
    _previewImage = [[UIImageView alloc]init];
    [self addSubview:_previewImage];
    
    _btnStartOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnStartOrPause setImage:[UIImage imageNamed:@"bofang-.png"] forState:UIControlStateNormal];
    [_btnStartOrPause addTarget:self action:@selector(onPressBtnStartOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnStartOrPause];
    
    //控制界面
    _controlPanel = [JGPlayerControlPanel playerControlPanel];
    _controlPanel.delegate = self;
    _controlPanel.state = JGPlayerControlState_Init;
    [self addSubview:_controlPanel];
    
    
    [_displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(self);
    }];
    
    [_previewImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(self);
    }];
    
    [_btnStartOrPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(self);
    }];
    
    [_controlPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(kOffScreenNumber);
        make.height.mas_equalTo(40);
    }];
    
    [PPYPlayEngine shareInstance].delegate = self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initialize];
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
    CGRect rect = self.displayView.frame;
    [PPYPlayEngine shareInstance].previewRect = rect;
    [super layoutSubviews];
}

-(void)dealloc{
    [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:YES];
    NSLog(@"PlayerView delloc!");
}


#pragma ---Setter,Getter---
-(void)setPlayerURL:(NSString *)playerURL{
    _playerURL = playerURL;
    
    [PPYMediaUtils getCoverImageFileWithInputFile:self.playerURL OutputWidth:375 OutputHeight:375 OutputFile:self.cachImagePath];
    NSData *imageData = [NSData dataWithContentsOfFile:self.cachImagePath];
    self.previewImage.image = [UIImage imageWithData:imageData];

    if(self.needPlayWhenAppear){
        if(!self.isPlaying){
            [self startPlay];
        }
    }
}

-(NSString *)cachImagePath{
    if(_cachImagePath == nil){
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _cachImagePath = [documentDir stringByAppendingPathComponent:@"previewImage"];
    }
    return _cachImagePath;
}

-(void)startPlay{
    [[PPYPlayEngine shareInstance] startPlayFromURL:self.playerURL WithType:PPYSourceType_VOD];
    [self.btnStartOrPause mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kOffScreenNumber, kOffScreenNumber));
    }];
    
    self.controlPanel.state = JGPlayerControlState_Start;
    [self.controlPanel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(0);
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
    NSString *errInfo = [NSString stringWithFormat:@"播放发生错误:%d",error];
    [self notifyMessageOnUI:errInfo];
    self.controlPanel.state = JGPlayerControlState_Init;
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
            self.controlPanel.duration = value;
            break;
        case PPYPlayEngineInfo_CurrentPlayBackTime:
            self.controlPanel.progress = value;
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
            [self.previewImage mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(CGPointMake(kOffScreenNumber, kOffScreenNumber));
            }];
            [self layoutIfNeeded];
            self.isPlaying = YES;
            break;
        case PPYPlayEngineStatus_RenderingStart:
            break;
        case PPYPlayEngineStatus_ReceiveEOF:
        {
            [self.btnStartOrPause mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
            [self.controlPanel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(kOffScreenNumber);
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
-(void)playControlPanelDidClickStartOrPauseButton:(JGPlayerControlPanel *)control{
    switch (control.state) {
        case JGPlayerControlState_Init:
            [self startPlay];
            break;
        case JGPlayerControlState_Start:
            [[PPYPlayEngine shareInstance] resume];
            break;
        case JGPlayerControlState_Pause:
            [[PPYPlayEngine shareInstance] pause];
            break;
    }
}
-(void)playControlPanel:(JGPlayerControlPanel *)controlPanel didSliderValueChanged:(float)newValue{
    [[PPYPlayEngine shareInstance] seekToPosition:newValue * [PPYPlayEngine shareInstance].duration];
}

-(void)notifyMessageOnUI:(NSString *)message{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:3.f];
}
@end
