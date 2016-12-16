//
//  LocalVideoCell.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/15.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "LocalVideoCell.h"
#import "AlbumVideoInfo.h"

@interface LocalVideoCell ()

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *imageViewArray;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labelArray;

@end

@implementation LocalVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshCellWithSourceList:(NSArray *)list
{
    for (UIImageView *imageView in self.imageViewArray) {
        imageView.hidden = YES;
    }
    
    for (UILabel *label in self.labelArray) {
        label.text = @"";
    }
    
    for (int i = 0; i < 4 && i < [list count]; i++) {
        UIImageView *imageView = [self.imageViewArray objectAtIndex:i];
        UILabel *label = [self.labelArray objectAtIndex:i];
        AlbumVideoInfo *info = [list objectAtIndex:i];
        
        imageView.image = info.thumbnail;
        imageView.hidden = NO;
        label.text = [NSString stringWithFormat:@"%@",[self timeformatFromSeconds:[info.duration integerValue]]];
    }
}

- (NSString*)timeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02zd",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02zd",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02zd",seconds%60];
    //format of time
    NSString *format_time = @"00:00";
    
    if ([str_hour integerValue] > 0) {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    
    return format_time;
}

@end
