//
//  UploadController.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/7.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "RecordController.h"
#import "Masonry.h"
#import <PPYLiveKit/PPYLiveKit.h>
#import "UploadController.h"
#import "PPProgressView.h"

#define KMAX_RECORD_TIME  1000

@interface RecordController () <PPYPushEngineDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (weak, nonatomic) IBOutlet UIButton *btnBeatify;
@property (weak, nonatomic) IBOutlet UIButton *btnTorch;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordTime;

@property (weak, nonatomic) IBOutlet UIImageView *imgDot;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *localBtn;

@property (nonatomic, strong) PPYPushEngine *pushEngine;
@property (copy, nonatomic) NSString *recordPath;

@property (assign, nonatomic) BOOL isRecording;

@property (nonatomic, strong) PPProgressView *progressView;
@property (assign, nonatomic) PPProgressViewStatus status;

@end

@implementation RecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}

-(void)viewDidAppear:(BOOL)animated{
    [self initUI];
}

-(void)dealloc{
    if(self.isRecording){
        [self stopRecord];
    }
}
-(void)initData{
    //设置录制路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.recordPath = [documentPath stringByAppendingPathComponent:@"defalut.mp4"];
    
    [self prepareForRecord];
}

-(void)initUI{
    [self.btnRecord setImage:[UIImage imageNamed:@"按住拍摄_未按"] forState:UIControlStateNormal];
    [self.btnBeatify setImage:[UIImage imageNamed:@"美颜开.png"] forState:UIControlStateNormal];
    [self.btnTorch setImage:[UIImage imageNamed:@"闪光灯.png"] forState:UIControlStateNormal];
    self.lblRecordTime.text =  [NSString stringWithFormat:@"0s"];
    
    self.pushEngine.preview = self.captureView;
    
    [self addTapGesture:self.captureView];
    
    self.progressView = [[PPProgressView alloc] initWithFrame:CGRectMake(0, self.captureView.frame.size.height - 3, self.captureView.frame.size.width, 3)];
    [self.captureView addSubview:self.progressView];
}

#pragma mark - UITapGestureRecognizer
- (void)addTapGesture:(UIView *)view
{
    // 单击事件
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleClickEvent:)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [view addGestureRecognizer:gesture];
    gesture.cancelsTouchesInView = YES;
    gesture = nil;
}

- (void)handleSingleClickEvent:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.captureView];
    [self.pushEngine doFocusOnPoint:touchPoint onView:self.captureView needDisplayLocation:YES];
}

- (IBAction)doBeauty:(id)sender {
    self.pushEngine.beautify = !self.pushEngine.isBeautify;
    if(self.pushEngine.beautify){
        [self.btnBeatify setImage:[UIImage imageNamed:@"美颜开.png"] forState:UIControlStateNormal];
    }else{
        [self.btnBeatify setImage:[UIImage imageNamed:@"美颜.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)doTorch:(id)sender {
    if(self.pushEngine.hasTorch){
        self.pushEngine.torch = !self.pushEngine.isTorch;
        if(self.pushEngine.isTorch){
            [self.btnTorch setImage:[UIImage imageNamed:@"闪光灯开.png"] forState:UIControlStateNormal];
        }else{
            [self.btnTorch setImage:[UIImage imageNamed:@"闪光灯.png"] forState:UIControlStateNormal];
        }
    }
}

-(void)controlTorch{
    
}

- (IBAction)doSwitchCamera:(id)sender {
    if(self.pushEngine.hasTorch){  // 翻转摄像头之前关闭闪光灯
        self.pushEngine.torch = NO;
        [self.btnTorch setImage:[UIImage imageNamed:@"闪光灯.png"] forState:UIControlStateNormal];
    }
    if([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1){
        AVCaptureDevicePosition current = self.pushEngine.cameraPosition;
        if(current == AVCaptureDevicePositionBack){
            self.pushEngine.cameraPosition = AVCaptureDevicePositionFront;
        }else if(current == AVCaptureDevicePositionFront){
            self.pushEngine.cameraPosition = AVCaptureDevicePositionBack;
        }
    }
}

- (IBAction)doExit:(id)sender {
    if(self.isRecording){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要放弃当前录制视频？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self stopRecord];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:OK];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:NO completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)doRecord:(id)sender {
    if(self.isRecording){
         [self stopRecord];
    }else{
         [self startRecord];
    }
}

- (IBAction)deleteBtnClicked:(id)sender
{
    if (self.status == PPProgressViewStatus_wait) {
        self.status = PPProgressViewStatus_Cancel;
        [self.progressView refreshProgressStatus:self.status];
    } else if (self.status == PPProgressViewStatus_Cancel) {
        [self.progressView deleteLastProgress];
        self.status = PPProgressViewStatus_wait;
    }
}

- (IBAction)localBtnClicked:(id)sender
{
    
}

- (IBAction)confirmBtnClicked:(id)sender
{
    
}

#pragma mark --<PPYPushEngineDelegate>
-(void)didStreamStateChanged:(PPYPushEngineStreamStatus)status{
    
    switch (status) {
        case PPYConnectionState_Connecting:
            break;
        case PPYConnectionState_Connected:
            break;
        case PPYConnectionStatus_Started:
            [self didRecordStarted];
            break;
        case PPYConnectionStatus_Ended:
            [self didRecordStoped];
            break;
    }
    NSLog(@"PPYPushEngineStreamStatus __%lu",(unsigned long)status);
}

-(void)didStreamErrorOccured:(PPYPushEngineErrorType)error{
    switch (error) {
        case PPYPushEngineError_Unknow:
            
            break;
        case PPYPushEngineError_ConnectFailed:
            
            break;
        case PPYPushEngineError_TransferFailed:
            
            break;
        case PPYPushEngineError_FatalError:
            
            break;
        case PPYPushEngineError_PoorNetwork:
            break;
    }
    NSLog(@"didStreamErrorOccured __%d",error);
}

-(void)didStreamInfoThrowOut:(PPYPushEngineStreamInfoType)type infoValue:(int)value{
 
    switch (type) {
        case PPYPushEngineInfo_BufferingBytes:
            break;
        case PPYPushEngineInfo_RealBirate:
            
            break;
        case PPYPushEngineInfo_RealFPS:
            
            break;
        case PPYPushEngineInfo_DowngradeBitrate:
            
            break;
        case PPYPUshEngineInfo_UpgradeBitrate:
            
            break;
        case PPYPushEngineInfo_PublishTime:
            self.lblRecordTime.text = [NSString stringWithFormat:@"%.1fs",(float)value / 10];
           [self.progressView refreshProgressWithValue:((float)value)/KMAX_RECORD_TIME];
            self.imgDot.hidden = value % 5;
            if(value >= KMAX_RECORD_TIME){   //步长100ms， 上限5分钟
                [self stopRecord];
            }
            break;
    }
    NSLog(@"didStreamInfoThrowOut %d__%d",type,value);
}

-(void)prepareForRecord{
    //初始化推流引擎
    PPYAudioConfiguration *audioConfigurate = [PPYAudioConfiguration defalutAudioConfiguration];
    PPYVideoConfiguration *videoConfigurate = [PPYVideoConfiguration videoConfigurationWithPreset:PPYCaptureSessionPreset360x640
                                                                                           andFPS:PPYCaptureFPSMedium
                                                                                        andBirate:1.2*1024]; //1.2Mbps
    self.pushEngine = [[PPYPushEngine alloc] initWithAudioConfiguration:audioConfigurate
                                                 andVideoConfiguration:videoConfigurate
                                                       pushRTMPAddress:self.recordPath];
    self.pushEngine.delegate = self;
    self.pushEngine.running = YES;
    self.pushEngine.beautify = YES;
    self.pushEngine.torch = NO;
    if(self.pushEngine.hasTorch){
        self.pushEngine.torch = NO;
    }
    
    if(self.pushEngine.hasFocus){//自动对焦
        self.pushEngine.autoFocus = YES;
    }
}

-(void)startRecord{
    
    if (self.status == PPProgressViewStatus_Cancel) {
        self.status = PPProgressViewStatus_wait;
        [self.progressView refreshProgressStatus:self.status];
    } else {
        [self.pushEngine start];
        self.btnRecord.userInteractionEnabled = NO;
        self.localBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
        self.confirmBtn.hidden = YES;
    }
}

-(void)didRecordStarted{
    self.isRecording = YES;
    [self.btnRecord setImage:[UIImage imageNamed:@"暂停.png"] forState:UIControlStateNormal];
    self.btnRecord.userInteractionEnabled = YES;
    
    self.status = PPProgressViewStatus_refreshing;
    [self.progressView refreshProgressStatus:self.status];
    
}

-(void)stopRecord{
    [self.pushEngine stop];
}

-(void)didRecordStoped{
    self.isRecording = NO;
    //[self.navigationController pushViewController:[[UploadController alloc]init] animated:YES];
    
    self.status = PPProgressViewStatus_wait;
    [self.progressView refreshProgressStatus:self.status];
    
    [self.btnRecord setImage:[UIImage imageNamed:@"按住拍摄_未按"] forState:UIControlStateNormal];
    self.deleteBtn.hidden = NO;
    self.confirmBtn.hidden = NO;
}

@end
