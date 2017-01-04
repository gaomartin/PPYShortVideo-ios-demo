//
//  LocalPlayerView.h
//  PPYShortVideo
//
//  Created by bobzhang on 17/1/4.
//  Copyright © 2017年 PPTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalPlayerView : UIView

@property (nonatomic, strong) NSArray *filePaths;

- (void)clearCache;
- (void)pause;

@end
