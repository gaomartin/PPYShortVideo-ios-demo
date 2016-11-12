//
//  mainViewController.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "mainViewController.h"
#import "RecordController.h"
#import "PlayListController.h"

@interface mainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UIButton *btnCinema;

@end

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCompleted) name:@"kUploadSuccess" object:nil];
    // Do any additional setup after loading the view from its nib.
}

-(void)initUI{
    self.btnRecord.backgroundColor =  [UIColor colorWithWhite:1 alpha:0.5];
    self.btnRecord.layer.cornerRadius = 10;
    [self.btnRecord clipsToBounds];
    
    self.btnCinema.layer.cornerRadius = 10;
    self.btnCinema.layer.borderWidth = 1.5;
    self.btnCinema.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    [self.btnCinema clipsToBounds];
}


- (IBAction)onPressedRecord:(id)sender {
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:[[RecordController alloc]init]];
    nv.navigationBarHidden = YES;
    [self presentViewController:nv animated:YES completion:nil];
}

- (IBAction)onPressedCinema:(id)sender {
    [self showPlayListUploadMessageNeeded:NO];
    
}

-(void)showPlayListUploadMessageNeeded:(BOOL)needOrNo{
    PlayListController *listVC = [[PlayListController alloc]init];
    listVC.needShowUploadSuccess = needOrNo;

    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController: listVC];
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.translucent = NO;
    bar.barTintColor = [UIColor colorWithRed:26.0/255 green:24.0/255 blue:37.0/255 alpha:1];;
    bar.tintColor = [UIColor whiteColor];
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:113.0/255 green:220.0/255 blue:249.0/255 alpha:1]}];
    
    [self presentViewController:nv animated:YES completion:nil];
}

-(void)uploadCompleted{
    [self showPlayListUploadMessageNeeded:YES];
}
@end
