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
@property (strong, nonatomic) UIImageView *previewImage;

@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,copy)   NSString *cachImagePath;
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
            [self.previewImage mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(CGPointMake(-1000, -1000));
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
