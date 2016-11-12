//
//  PlayerController.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/8.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "PlayerController.h"
#import "PlayerView.h"

@interface PlayerController ()
@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@end

@implementation PlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"curretn player url = %@",self.playerURL);
    self.playerView.needPlayWhenAppear = self.needPlayWhenAppear;
    self.playerView.playerURL = self.playerURL;
    // Do any additional setup after loading the view from its nib.
}

-(void)dealloc{
    NSLog(@"PlayerController delloc");
}
@end
