//
//  SelectVideoViewCell.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/16.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "SelectVideoViewCell.h"
#import "NSString+time.h"
#import "BZVideoInfo.h"

@implementation SelectVideoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)deleteBtnClicked:(id)sender;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]) {
        [self.delegate deleteCell:self];
    }
}

- (void)refreshCellWithInfo:(BZVideoInfo *)videoInfo
{
    self.fileIdentifier = videoInfo.path;
    
    if (videoInfo.thumbnail) {//本地视频
        self.imageView.image = videoInfo.thumbnail;
    } else {
        NSString *preImagePath = [self cachImagePath];
        [PPYThumbnailInfo getCoverImageFileWithInputFile:videoInfo.path OutputWidth:75 OutputHeight:75 OutputFile:preImagePath];
        NSData *imageData = [NSData dataWithContentsOfFile:preImagePath];
        self.imageView.image = [UIImage imageWithData:imageData];
    }
    
    self.timeLabel.text = [NSString timeformatFromSeconds:(videoInfo.endPos - videoInfo.startPos)/1000];
    
    self.backgroudImageView.hidden = !videoInfo.isSelected;
}

//只针对录制视频
-(NSString *)cachImagePath
{
    NSString *path = @"";
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [documentDir stringByAppendingPathComponent:@"Record/previewImage"];
    return path;
}

@end
