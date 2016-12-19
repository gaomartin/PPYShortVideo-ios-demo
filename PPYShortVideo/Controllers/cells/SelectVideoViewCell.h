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

@interface SelectVideoViewCell : UICollectionViewCell

@property (nonatomic, weak) id <PPCollectionCellDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end
