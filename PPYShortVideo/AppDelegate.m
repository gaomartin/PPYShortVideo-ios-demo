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
    [self getRecordFileDir];
    
    return YES;
}

- (void)setAPPWindow
{
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
}

- (void)setAppRootViewController
{
    mainViewController *rootViewController = [[mainViewController alloc]init];
    [rootViewController.view setFrame:[UIScreen mainScreen].bounds];
    
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    nv.navigationBarHidden = YES;
    self.window.rootViewController = nv;
}

- (NSString *)getRecordFileDir
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

@end
