//
//  PPYStreamlessPlayer.h
//  
//
//  Created by jimmygao on 2016/12/27.
//
//  Copyright © 2016年 高国栋. All rights reserved.

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface PPYSeamlessPlayer : NSObject

@property (assign, nonatomic,readonly) BOOL isPlaying;
@property (strong, nonatomic) AVQueuePlayer *player;
@property (assign, nonatomic, readonly) CMTime duration;
@property (assign, nonatomic, readonly) CMTime currentTime;
@property (strong, nonatomic, readonly) NSMutableArray *playerItems; // <AVPlayerItem *>

-(instancetype)initWithSourcePaths:(NSArray *)filePaths;

-(void)play;
-(void)pause;

-(void)seekToTime:(CMTime)time;

-(void)switchToPlayerSourcesOfIndex:(NSUInteger)index;
-(void)addPlayerSource:(NSString *)filePath;
-(void)removePlaySourceOfIndex:(NSUInteger)index;
-(void)exchangePlayerOrderAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;  //会seek到idx2的地方；
-(void)removeAllPlayerSources;

@end
