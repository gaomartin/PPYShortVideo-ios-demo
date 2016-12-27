//
//  LocalVideoCell.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/15.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "LocalVideoCell.h"
#import "AlbumVideoInfo.h"
#import "NSString+time.h"

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
        label.text = [NSString timeformatFromSeconds:[info.duration integerValue]];
    }
}


@end
