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

@interface BZVideoEditViewController ()

@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (strong, nonatomic) JGCycleProgressView *progressView;

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

@end
