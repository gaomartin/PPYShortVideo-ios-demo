//
//  LocalPlayerView.m
//  PPYShortVideo
//
//  Created by bobzhang on 17/1/4.
//  Copyright © 2017年 PPTV. All rights reserved.
//

#import "LocalPlayerView.h"
#import "Masonry.h"
#import "JGPlayerControlPanel.h"
#import "MBProgressHUD.h"
#import "LocalPlayerLayerView.h"

@interface LocalPlayerView ()<JGPlayControlPanelDelegate>

@property (nonatomic, strong) PPYSeamlessPlayer *seamlessPlayer;
@property (nonatomic, strong) LocalPlayerLayerView *layerView;

@property (nonatomic, strong) UIButton *btnStartOrPause;
@property (nonatomic, strong) UIImageView *previewImage;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy)   NSString *cachImagePath;

@property (nonatomic, strong) JGPlayerControlPanel *controlPanel;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LocalPlayerView


-(void)initialize{
    
    self.layerView = [[LocalPlayerLayerView alloc]init];
    [self addSubview:_layerView];
    
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
    
    [_layerView mas_makeConstraints:^(MASConstraintMaker *make) {
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

-(void)dealloc{
    
    NSLog(@"LocalPlayerView delloc!");
}

- (void)clearCache
{
    //TODO: 播放完成后, 退出会crash
    self.seamlessPlayer = nil;
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)removePreImage
{
    [self.previewImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kOffScreenNumber, kOffScreenNumber));
    }];
}

- (void)refreshUI
{
    [_previewImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.btnStartOrPause mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

-(void)doMonitor
{
    double duration = CMTimeGetSeconds(self.seamlessPlayer.duration);
    double currentTime = CMTimeGetSeconds(self.seamlessPlayer.currentTime);
    NSLog(@"duration = %f,current time = %f",duration, currentTime);
    
    self.controlPanel.progress = currentTime * 1000;
    self.controlPanel.duration = duration * 1000;
}

#pragma ---Setter,Getter---
- (void)setFilePaths:(NSArray *)filePaths
{
    if (filePaths != _filePaths) {
        _filePaths = filePaths;
        [self refreshUI];
        [self startPlay];
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

    self.seamlessPlayer = [[PPYSeamlessPlayer alloc]initWithSourcePaths:self.filePaths];
    
    self.layerView.player = self.seamlessPlayer.player;
    
    [PPYThumbnailInfo getCoverImageFileWithInputFile:[_filePaths objectAtIndex:0] OutputWidth:375 OutputHeight:375 OutputFile:self.cachImagePath];
    NSData *imageData = [NSData dataWithContentsOfFile:self.cachImagePath];
    self.previewImage.image = [UIImage imageWithData:imageData];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doMonitor) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

- (void)play
{
    [self.seamlessPlayer play];
    
    [self.btnStartOrPause mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kOffScreenNumber, kOffScreenNumber));
    }];
    
    [self.previewImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kOffScreenNumber, kOffScreenNumber));
    }];
    
    self.controlPanel.state = JGPlayerControlState_Start;
    [self.controlPanel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(0);
    }];
    
    [self layoutIfNeeded];
}

- (void)pause
{
   [self.seamlessPlayer pause];
}

- (void)seekToPostion:(NSTimeInterval)position
{
    CMTime seekTime = CMTimeMakeWithSeconds(position/1000, 1000);
    NSLog(@"seekTime = %f",CMTimeGetSeconds(seekTime));
    
    [self.seamlessPlayer seekToTime:seekTime];
}

-(void)onPressBtnStartOrPause:(UIButton *)sender{
    [self play];
}

-(void)playControlPanelDidClickStartOrPauseButton:(JGPlayerControlPanel *)control
{
    switch (control.state) {
        case JGPlayerControlState_Init:
            [self startPlay];
            break;
        case JGPlayerControlState_Start:
            [self.seamlessPlayer play];
            break;
        case JGPlayerControlState_Pause:
            [self.seamlessPlayer pause];
            break;
    }
}

//拖动
-(void)playControlPanel:(JGPlayerControlPanel *)controlPanel didSliderValueChanged:(float)newValue
{
    //TODO: 拖到最后, 会出问题, 屏幕一直闪, 无法跳转
    double duration = CMTimeGetSeconds(self.seamlessPlayer.duration);
    if (newValue > 0.95) {
        newValue = 0.95;
    }
    CMTime seekTime = CMTimeMakeWithSeconds(newValue * duration, 1000);
    NSLog(@"seekTime = %f",CMTimeGetSeconds(seekTime));
    
    [self.seamlessPlayer seekToTime:seekTime];
}

@end
