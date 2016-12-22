//
//  BZVideoEditViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/20.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "BZVideoEditViewController.h"
#import "PlayListHelper.h"
#import "JGCycleProgressView.h"
#import "PlayerView.h"
#import "Masonry.h"
#import "WebAPI.h"

@interface BZVideoEditViewController ()

@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (strong, nonatomic) JGCycleProgressView *progressView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation BZVideoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.playerView.playerURL = self.mediaProduct.url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadBtnClicked:(id)sender
{
    PlayListHelper *helper = [[PlayListHelper alloc]init];
    
    NSString *recordFilePath = self.mediaProduct.url;
    NSLog(@"product recordFilePath=%@",recordFilePath);
    [self presentProgressView];
    
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

- (void)cancelUpload
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
    [WebAPI uploadCancel];
}

#pragma mark --Presenter--

-(JGCycleProgressView *)progressView{
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
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(0, 20, 50, 44);
    [self.cancelButton setImage:[UIImage imageNamed:@"左上角的关闭"] forState:UIControlStateNormal];
    [self.cancelButton addTarget: self action:@selector(cancelUpload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerView);
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
