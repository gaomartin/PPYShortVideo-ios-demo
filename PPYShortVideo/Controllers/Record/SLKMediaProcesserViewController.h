//
//  SLKMediaProcesserViewController.h
//  MediaStreamerDemo
//
//  Created by Think on 2016/11/22.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLKMediaProcesserViewController : UIViewController

- (IBAction)backAction:(id)sender;
- (IBAction)startAction:(id)sender;
- (IBAction)stopAction:(id)sender;

+ (void)presentFromViewController:(UIViewController *)viewController;

@end
