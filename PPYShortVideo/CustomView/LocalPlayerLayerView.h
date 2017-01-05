//
//  LocalPlayerLayerView.h
//  PPYShortVideo
//
//  Created by bobzhang on 17/1/5.
//  Copyright © 2017年 PPTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalPlayerLayerView : UIView

@property AVPlayer *player;
@property (readonly) AVPlayerLayer *playerLayer;

@end
