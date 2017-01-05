//
//  LocalPlayerLayerView.m
//  PPYShortVideo
//
//  Created by bobzhang on 17/1/5.
//  Copyright © 2017年 PPTV. All rights reserved.
//

#import "LocalPlayerLayerView.h"

@implementation LocalPlayerLayerView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
