//
//  AppDelegate.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "AppDelegate.h"
#import "mainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self setAPPWindow];
    [self setAppRootViewController];
    
    return YES;
}


-(void)setAPPWindow{
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
}
-(void)setAppRootViewController{
    
    mainViewController *rootViewController = [[mainViewController alloc]init];
    [rootViewController.view setFrame:[UIScreen mainScreen].bounds];
    
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    nv.navigationBarHidden = YES;
    self.window.rootViewController = nv;
}
@end
