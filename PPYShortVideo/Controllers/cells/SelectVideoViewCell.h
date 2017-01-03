//
//  SelectVideoViewCell.h
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/16.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectVideoViewCell;
@protocol PPCollectionCellDelegate <NSObject>

- (void)deleteCell:(SelectVideoViewCell *)cell;

@end

@class BZVideoInfo;
@interface SelectVideoViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *backgroudImageView;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) id <PPCollectionCellDelegate> delegate;

@property (nonatomic, strong) NSString *fileIdentifier;

- (void)refreshCellWithInfo:(BZVideoInfo *)videoInfo;

@end
