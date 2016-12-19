//
//  SelectVideoViewCell.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/16.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "SelectVideoViewCell.h"

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

@end
