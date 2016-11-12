//
//  PlayerController.h
//  PPYShortVideo
//
//  Created by admin on 2016/11/8.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerController : UIViewController
@property (copy, nonatomic) NSString *playerURL;
@property (assign,nonatomic) BOOL needPlayWhenAppear;
@end
