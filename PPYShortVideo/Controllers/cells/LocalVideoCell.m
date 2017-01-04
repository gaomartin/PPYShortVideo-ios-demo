//
//  LocalVideoCell.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/15.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "LocalVideoCell.h"
#import "NSString+time.h"
#import "BZVideoInfo.h"

@interface LocalVideoCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;

@end

@implementation LocalVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)refreshCellWithInfo:(BZVideoInfo *)videoInfo
{
    self.imageView.image = videoInfo.thumbnail;
    self.timeLabel.text = [NSString timeformatFromSeconds:(NSInteger)(videoInfo.total/1000)];
    self.coverImageView.hidden = !videoInfo.isAddVideo;
}


@end
