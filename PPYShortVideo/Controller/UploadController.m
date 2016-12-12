//
//  UploadController.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "UploadController.h"
#import "PlayListHelper.h"
#import "JGCycleProgressView.h"
#import "Masonry.h"
#import "PlayerView.h"
#import "MBProgressHUD.h"

@interface UploadController ()
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;

@property (copy, nonatomic) NSString *recordFilePath;
@property (strong, nonatomic) JGCycleProgressView *progressView;
@end

@implementation UploadController

#pragma mark --LifeCycle--
- (void)viewDidLoad {
    [super viewDidLoad];
    self.playerView.playerURL = self.recordFilePath;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark --Actions--
- (IBAction)doUpload:(id)sender {
    
    PlayListHelper *helper = [[PlayListHelper alloc]init];

    NSLog(@"self.recordFilepath = %@",self.recordFilePath);
    __weak typeof(self) weakSelf = self;
    [helper uploadShortVideo:self.recordFilePath Progress:^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentProgressView];
            weakSelf.progressView.label.text = [NSString stringWithFormat:@"%d%%",(int)(progress.fractionCompleted * 100)];
            [weakSelf.progressView drawProgress:progress.fractionCompleted];
            weakSelf.btnUpload.userInteractionEnabled = NO;
        });
    } Success:^{
        weakSelf.btnUpload.userInteractionEnabled = YES;
        [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUploadSuccess" object:nil];
    } Failured:^(NetworkErrorType type, int errcode, NSString *msg) {
        weakSelf.btnUpload.userInteractionEnabled = YES;
        [weakSelf processMessage:type code:errcode info:msg];
    }];
}

- (IBAction)doExit:(id)sender {
    [self notifyMessageOnUI:@"后台上传中"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --Getter,Setter--
-(NSString *)recordFilePath{
    if(_recordFilePath == nil){
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _recordFilePath = [documentPath stringByAppendingPathComponent:@"defalut.mp4"];
    }
    return _recordFilePath;
}

-(JGCycleProgressView *)progressView{
    if(_progressView == nil){
        _progressView = [[JGCycleProgressView alloc]init];
    }
    return _progressView;
}

#pragma mark --Presenter--
-(void)presentProgressView{
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerView);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
}

-(void)notifyMessageOnUI:(NSString *)message{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:3.f];
}

-(void)processMessage:(NetworkErrorType)type code:(int)code info:(NSString *)msg{
//    if(type == WebAPI_ReturnError){
////        [self notifyMessageOnUI:@"连接错误，上传失败"];
//    }else if(type == AFNetworking_Error){
////        [self notifyMessageOnUI:@"网络异常,上传失败"];
//    }
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"上传失败，重新上传试试？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doUpload:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:OK];
    [alert addAction:cancel];
}

@end
