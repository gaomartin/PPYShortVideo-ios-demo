//
//  RecordController.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/7.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "RecordController.h"
#import "Masonry.h"
#import <PPYLiveKit/PPYLiveKit.h>
#import "PPProgressView.h"
#import "LocalVideoAddViewController.h"
#import "BZVideoInfo.h"
#import "JGCycleProgressView.h"
#import "BZChiefEditViewController.h"

#ifdef DEBUG
#define KMAX_RECORD_TIME  100
#else
#define KMAX_RECORD_TIME  300
#endif

#ifdef DEBUG
#define KMIN_RECORD_TIME_TO_MERGE  5
#else
#define KMIN_RECORD_TIME_TO_MERGE  10
#endif


@interface RecordController () <PPYPushEngineDelegate, UIGestureRecognizerDelegate,SLKMediaMergerDelegate>

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
@property (assign, nonatomic) BOOL isExitWhenRecording;

@property (nonatomic, strong) PPProgressView *progressView;
@property (assign, nonatomic) PPProgressViewStatus status;
@property (assign, nonatomic) NSInteger recordIndex;
@property (nonatomic, strong) NSMutableArray *recordInfoArray;
@property (nonatomic, assign) NSTimeInterval lastDuration;//前面录制的总时间
//合成
@property (nonatomic, strong) SLKMediaMerger *slkMediaMerger;
@property (nonatomic, strong) SLKMediaMaterialGroup *slkMediaMaterialGroup;
@property (nonatomic, strong) SLKMediaProduct* slkMediaProduct;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, strong) JGCycleProgressView *cycleProgressView;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation RecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createRecordFileDir];
    self.recordInfoArray = [NSMutableArray array];
    [self prepareForRecord];
    self.recordIndex = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initUI];
}

-(void)dealloc{
    if(self.isRecording){
        [self stopRecord];
    }
}

- (NSString *)createRecordFileDir
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDirPath = [documentPath stringByAppendingPathComponent:@"Record"];
    NSLog(@"recordDirPath = %@",recordDirPath);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:recordDirPath isDirectory:&isDir];
    if(!(isDirExist && isDir)){
           BOOL bCreateDir = [fileManager createDirectoryAtPath:recordDirPath withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"创建文件夹失败！");
            } else {
                NSLog(@"创建文件夹成功，文件路径%@",recordDirPath);
            }
       }
    
    return recordDirPath;
}

-(NSString *)createRecordPath
{
    //设置录制路径
    self.recordIndex ++;
    NSString *path = [NSString stringWithFormat:@"%@/defalut%zd.mp4",[self createRecordFileDir], self.recordIndex];
    
    return path;
}

-(void)initUI{
    [self.btnRecord setImage:[UIImage imageNamed:@"按住拍摄_未按"] forState:UIControlStateNormal];
    [self.btnBeatify setImage:[UIImage imageNamed:@"美颜开.png"] forState:UIControlStateNormal];
    [self.btnTorch setImage:[UIImage imageNamed:@"闪光灯.png"] forState:UIControlStateNormal];
    self.lblRecordTime.text = [NSString stringWithFormat:@"0s"];
    self.confirmBtn.enabled = NO;
    
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

- (IBAction)doSwitchCamera:(id)sender
{
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

- (IBAction)doExit:(id)sender
{
    if (self.isRecording || [self.recordInfoArray count]) {//正在录制, 或者已经有录制的文件
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定放弃当前录制视频？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.isExitWhenRecording = YES;
            if (self.isRecording) {//正在录制
                 [self stopRecord];
            } else {//停止录制, 且已经有录制的文件
                [self exitRecord];
                [self checkButtonStatus];
            }
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:OK];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:NO completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)doRecord:(id)sender
{
    if(self.isRecording) {
        [self stopRecord];
    } else {
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
        [self.recordInfoArray removeLastObject];
        self.status = PPProgressViewStatus_wait;
        
        self.lastDuration = [self getTotalRecordDuration];
        self.lblRecordTime.text = [NSString stringWithFormat:@"%.fs",self.lastDuration / 1000];
        [self checkButtonStatus];
    }
}

- (IBAction)localBtnClicked:(id)sender
{
    LocalVideoAddViewController *localView = [[LocalVideoAddViewController alloc] init];
    [self presentViewController:localView animated:YES completion:nil];
}

- (IBAction)confirmBtnClicked:(id)sender
{
    [self mergeVideoPrepare];
    [self startMerge];
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
        {
            float total = (float)value + self.lastDuration/100;
            self.lblRecordTime.text = [NSString stringWithFormat:@"%.1fs",total / 10];
           [self.progressView refreshProgressWithValue:(float)value/(KMAX_RECORD_TIME * 10)];
            self.imgDot.hidden = (int)total % 5;
            if(total >= KMAX_RECORD_TIME * 10){   //步长100ms， 上限5分钟
                [self stopRecord];
                self.lblRecordTime.text = [NSString stringWithFormat:@"%.fs",(float)total / 10];
            }
        }
            break;
    }
    NSLog(@"didStreamInfoThrowOut %d__%d",type,value);
}

#pragma mark - record

-(void)prepareForRecord{
    //初始化推流引擎
    PPYAudioConfiguration *audioConfigurate = [PPYAudioConfiguration defalutAudioConfiguration];
    PPYVideoConfiguration *videoConfigurate = [PPYVideoConfiguration videoConfigurationWithPreset:PPYCaptureSessionPreset360x640
                                                                                           andFPS:PPYCaptureFPSMedium
                                                                                        andBirate:1.2*1024]; //1.2Mbps
    self.pushEngine = [[PPYPushEngine alloc] initWithAudioConfiguration:audioConfigurate
                                                andVideoConfiguration:videoConfigurate];
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
        self.recordPath = [self createRecordPath];
        [self.pushEngine startWithAddress:self.recordPath];
        
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

    self.status = PPProgressViewStatus_wait;
    [self.progressView refreshProgressStatus:self.status];
    [self addVideoInfo];
    
    [self.btnRecord setImage:[UIImage imageNamed:@"按住拍摄_未按"] forState:UIControlStateNormal];
    self.deleteBtn.hidden = NO;
    self.confirmBtn.hidden = NO;
    
    if (self.isExitWhenRecording) {
        [self exitRecord];
    }
    
    [self checkButtonStatus];
    
    if (self.lastDuration >= KMAX_RECORD_TIME * 1000) {//录制时间满后, 自动合成跳转
        [self confirmBtnClicked:nil];
    }
}

- (void)addVideoInfo
{
    BZVideoInfo *info = [[BZVideoInfo alloc] init];
    info.path = self.recordPath;
    info.startPos = 0;
    info.endPos = [self.pushEngine syncGetMediaDurationWithInputFile:self.recordPath];
    
    [self.recordInfoArray addObject:info];
}

- (void)exitRecord
{
    self.isExitWhenRecording = NO;
    self.recordIndex = 0;
    self.lblRecordTime.text = [NSString stringWithFormat:@"0s"];
    
    [self.recordInfoArray removeAllObjects];
    [self.progressView clear];
}

- (void)checkButtonStatus
{
    self.lastDuration = [self getTotalRecordDuration];
    if(self.lastDuration > KMIN_RECORD_TIME_TO_MERGE * 1000) {
        self.confirmBtn.enabled = YES;
        [self.confirmBtn setImage:[UIImage imageNamed:@"组-13"] forState:UIControlStateNormal];
    } else {
        self.confirmBtn.enabled = NO;
        [self.confirmBtn setImage:[UIImage imageNamed:@"组-12"] forState:UIControlStateNormal];
    }
    
    if ([self.recordInfoArray count] == 0) {
        self.localBtn.hidden = NO;
        self.deleteBtn.hidden = YES;
    }
}

- (NSTimeInterval)getTotalRecordDuration
{
    NSTimeInterval totalDuration = 0.f;
    for (int i=0; i<[self.recordInfoArray count]; i++) {
        BZVideoInfo *info = [self.recordInfoArray objectAtIndex:i];
        totalDuration += info.endPos - info.startPos;
    }
    return totalDuration;
}

#pragma mark - merge video

- (void)mergeVideoPrepare
{
    if (!self.slkMediaMerger) {
        self.slkMediaMerger = [[SLKMediaMerger alloc] init];
    }
    self.slkMediaMerger.delegate = self;
    
    if (!self.slkMediaMaterialGroup) {
        self.slkMediaMaterialGroup = [[SLKMediaMaterialGroup alloc] init];
    }
    
    if (!self.slkMediaProduct) {
        self.slkMediaProduct = [[SLKMediaProduct alloc] init];
    }
}

- (void)startMerge
{
    self.totalDuration = 0;
    
    for (int i=0; i<[self.recordInfoArray count]; i++) {
        BZVideoInfo *info = [self.recordInfoArray objectAtIndex:i];
        
        SLKMediaMaterial *slkMediaMaterial = [[SLKMediaMaterial alloc] init];
        slkMediaMaterial.url = info.path;
        slkMediaMaterial.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_VIDEO_AUDIO;
        slkMediaMaterial.startPos = info.startPos;
        slkMediaMaterial.endPos = info.endPos;
        slkMediaMaterial.weight = 1.0f;
        self.totalDuration += info.endPos - info.startPos;
        [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial];
        
        NSLog(@"record info startPos=%.2f, endPos=%.2f",info.startPos/1000, info.endPos/1000);
    }
    
    self.slkMediaProduct.url = [[self createRecordFileDir] stringByAppendingString:@"/product.mp4"];
    self.slkMediaProduct.hasVideo = YES;
    self.slkMediaProduct.videoSize = CGSizeMake(480,640);
    self.slkMediaProduct.hasAudio = YES;
    self.slkMediaProduct.bps = 2000;
    
    [self.slkMediaMerger initializeWithInputMaterialGroup:self.slkMediaMaterialGroup WithMergeAlgorithm:SLK_MEDIA_MERGE_ALGORITHM_TIMELINE WithOutputMediaProduct:self.slkMediaProduct];
    
    [self.slkMediaMaterialGroup removeAllMediaMaterials];
    
    [self.slkMediaMerger start];
    [self presentCycleProgressView];
}

#pragma mark - SLKMediaMergerDelegate

- (void)gotErrorWithErrorType:(int)errorType
{
    NSLog(@"gotErrorWithErrorType errorType:%d",errorType);
}

- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue
{
    if (infoType == SLK_MEDIA_PROCESSER_INFO_WRITE_TIMESTAMP) {
        NSLog(@"Write TimeStamp:%d",infoValue);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更UI
            self.cycleProgressView.label.text = [NSString stringWithFormat:@"%zd%%",(int)(infoValue /self.totalDuration * 100 * 1000)];
            [self.cycleProgressView drawProgress:infoValue/self.totalDuration * 1000];
        });
    }
}

- (void)didEnd
{
    NSLog(@"didEnd");
    [self pushToEditView];
}

- (void)pushToEditView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.slkMediaMerger stop];
        [self.slkMediaMerger terminate];
       
        BZChiefEditViewController *editView = [[BZChiefEditViewController alloc] init];
        editView.mediaProduct = self.slkMediaProduct;
        editView.videoArray = [NSMutableArray arrayWithArray: self.recordInfoArray];
        [self.navigationController pushViewController:editView animated:YES];
        
        [self removeCycleProgressView];
        [self.recordInfoArray removeAllObjects];
        [self checkButtonStatus];
        self.lblRecordTime.text = [NSString stringWithFormat:@"0s"];
     });
}

#pragma mark - JGCycleProgressView
-(JGCycleProgressView *)cycleProgressView
{
    if(_cycleProgressView == nil){
        _cycleProgressView = [[JGCycleProgressView alloc]init];
    }
    return _cycleProgressView;
}

-(void)presentCycleProgressView
{
    self.backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backgroundView];
    self.backgroundView.alpha = 0.5;
    
    [self.view addSubview:self.cycleProgressView];
    [self.cycleProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
}

- (void)removeCycleProgressView
{
    if (self.backgroundView.superview) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    
    if (self.cycleProgressView.superview) {
        [self.cycleProgressView removeFromSuperview];
        self.cycleProgressView = nil;
    }
}

@end
