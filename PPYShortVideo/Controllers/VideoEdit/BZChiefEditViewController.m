//
//  BZChiefEditViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/20.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "BZChiefEditViewController.h"
#import "PlayListHelper.h"
#import "JGCycleProgressView.h"
#import "PlayerView.h"
#import "Masonry.h"
#import "WebAPI.h"
#import "BZVideoEditViewController.h"

@interface BZChiefEditViewController ()<PPYMediaMergerDelegate>

@property (strong, nonatomic) IBOutlet LocalPlayerView *localPlayerView;
@property (strong, nonatomic) JGCycleProgressView *progressView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) PPYMediaMerger *mediaMerger;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) BOOL isNeedMerge;

@end

@implementation BZChiefEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [BZEditVideoInfo shareInstance].editVideoType = BZEditVideoType_FromRecordView;
    
    NSMutableArray *pathArray = [NSMutableArray array];
    for (BZVideoInfo *info in [BZEditVideoInfo shareInstance].editVideoArry) {
        [pathArray addObject:info.path];
    }
    self.localPlayerView.filePaths = pathArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.localPlayerView clearCache];
    self.localPlayerView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editBtnClicked:(id)sender
{
    BZVideoEditViewController *edit = [[BZVideoEditViewController alloc] init];
    [self.navigationController pushViewController:edit animated:YES];
    [self.localPlayerView pause];
}

- (IBAction)uploadBtnClicked:(id)sender
{
    self.totalDuration = 0;
    self.isNeedMerge = NO;
    
    for (BZVideoInfo *info in [BZEditVideoInfo shareInstance].editVideoArry) {
        if (info.startPos > 0 || info.endPos < info.total) {
            self.isNeedMerge = YES;
        }
        
        self.totalDuration += info.endPos - info.startPos;
    }
    
    if (self.totalDuration > 5 * 60 * 1000) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"当前最多传 5min 的视频" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self presentProgressView];
    
    if (self.isNeedMerge) {
        [self startMerge];
    } else {
        [self uploadVideo];
    }
}

- (void)uploadVideo
{
    PlayListHelper *helper = [[PlayListHelper alloc]init];
    
    NSString *recordFilePath = [BZEditVideoInfo shareInstance].mediaProduct.url;
    NSLog(@"product recordFilePath=%@",recordFilePath);
    
    __weak typeof(self) weakSelf = self;
    [helper uploadShortVideo:recordFilePath Progress:^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.label.text = [NSString stringWithFormat:@"%d%%",(int)(progress.fractionCompleted * 100)];
            [weakSelf.progressView drawProgress:progress.fractionCompleted];
        });
    } Success:^{
        [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUploadSuccess" object:nil];
    } Failured:^(NetworkErrorType type, int errcode, NSString *msg) {
        [weakSelf processMessage:type code:errcode info:msg];
    }];
}

- (void)cancelUploadBtnClicked
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定取消上传视频？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cancelUpload];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:OK];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)cancelUpload
{
    [self removeProgressView];
    [WebAPI uploadCancel];
}

- (void)removeProgressView
{
    if (self.backgroundView.superview) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    if (self.cancelButton.superview) {
        [self.cancelButton removeFromSuperview];
        self.cancelButton = nil;
    }
    if (self.progressView.superview) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}

#pragma mark - merge video

- (void)startMerge
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDirPath = [documentPath stringByAppendingPathComponent:@"Record"];
    
    NSString *product = [recordDirPath stringByAppendingString:@"/product.mp4"];
    self.mediaMerger = [[PPYMediaMerger alloc] initWithProductPath:product andVideoSize:CGSizeMake(480,640)];
    self.mediaMerger.delegate = self;
    
    for (int i=0; i<[[BZEditVideoInfo shareInstance].editVideoArry count]; i++) {
        BZVideoInfo *info = [[BZEditVideoInfo shareInstance].editVideoArry objectAtIndex:i];
        
        PPYMediaInfo *mediaInfo = [[PPYMediaInfo alloc] init];
        mediaInfo.mediaPath = info.path;
        mediaInfo.startPos = info.startPos;
        mediaInfo.endPos = info.endPos;
        
        [self.mediaMerger addMediaMaterial:mediaInfo];
        
        NSLog(@"record info startPos=%.2f, endPos=%.2f",info.startPos/1000, info.endPos/1000);
    }
    
    [self.mediaMerger start];
}

#pragma mark - PPYMediaMergerDelegate

- (void)gotErrorWithErrorType:(int)errorType
{
    NSLog(@"gotErrorWithErrorType errorType:%d",errorType);
}

- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue
{
    if (infoType == PPY_MEDIA_PROCESSER_INFO_WRITE_TIMESTAMP) {
        NSLog(@"Write TimeStamp:%d",infoValue);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更UI
            self.progressView.label.text = [NSString stringWithFormat:@"%zd%%",(int)(infoValue /self.totalDuration * 100 * 1000)];
            [self.progressView drawProgress:infoValue/self.totalDuration * 1000];
        });
    }
}

- (void)didEnd
{
    NSLog(@"didEnd");
    self.isNeedMerge = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeProgressView];
        [self presentProgressView];
        [self uploadVideo];
    });
}

#pragma mark --Presenter--

-(JGCycleProgressView *)progressView
{
    if(_progressView == nil){
        _progressView = [[JGCycleProgressView alloc]init];
    }
    return _progressView;
}

-(void)presentProgressView
{
    self.backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backgroundView];
    self.backgroundView.alpha = 0.5;
    
    if (!self.isNeedMerge) {//merge的时候, 不创建cancel按钮
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(0, 20, 50, 44);
        [self.cancelButton setImage:[UIImage imageNamed:@"左上角的关闭"] forState:UIControlStateNormal];
        [self.cancelButton addTarget: self action:@selector(cancelUploadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelButton];
        
        self.progressView.detailLabel.text = @"正在发布";
    } else {
        self.progressView.detailLabel.text = @"视频处理中...";
    }
    
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.localPlayerView);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
}

-(void)processMessage:(NetworkErrorType)type code:(int)code info:(NSString *)msg
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"上传失败，重新上传试试？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf uploadBtnClicked:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:OK];
    [alert addAction:cancel];
}

@end
