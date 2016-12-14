//
//  PPProgressView.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/14.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "PPProgressView.h"
#import "UIColor+BZHex.h"
#import "PPObjectSafe.h"


@implementation PPProgressModel

@end


@interface PPProgressView ()

@property (nonatomic, assign) float curValue;
@property (nonatomic, strong) UIView *pointView;
@property (nonatomic, strong) NSMutableArray *progressArray;

@end


@implementation PPProgressView

-(void)initialize
{
    self.backgroundColor = [UIColor grayColor];
    
    self.progressArray = [NSMutableArray array];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initialize];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self initialize];
    }
    return self;
}

#pragma mark -
- (void)refreshProgressWithValue:(CGFloat)value
{
    PPProgressModel *progressModel = (PPProgressModel *)[self.progressArray lastObject];
    UIView *view = progressModel.progressView;
    progressModel.progressTime = value;
    
    CGRect frame = view.frame;
    frame.size.width = value * self.frame.size.width;
    frame.origin.x = ([self allValue] - value) * self.frame.size.width + ([self.progressArray count]-1) * 2;
    view.frame = frame;
    
    CGRect size = self.pointView.frame;
    size.origin.x = [self allValue] * self.frame.size.width + ([self.progressArray count]-1) * 2;
    self.pointView.frame = size;
}

- (void)refreshProgressStatus:(PPProgressViewStatus)status
{
    PPProgressModel *progressModel = (PPProgressModel *)[self.progressArray lastObject];
    UIView *view = progressModel.progressView;
    
    switch (status) {
        case PPProgressViewStatus_wait:
            view.alpha = 1.0;
            
            break;
        case PPProgressViewStatus_refreshing:
            [self.progressArray addObject:[self createNewProgressModel]];
            
            break;
        case PPProgressViewStatus_Cancel:
            view.alpha = 0.5;
            
            break;
        case PPProgressViewStatus_Delete:
            [view removeFromSuperview];
            [self.progressArray removeLastObject];
            
            break;
        default:
            break;
    }
}

- (void)deleteLastProgress
{
    PPProgressModel *progressModel = (PPProgressModel *)[self.progressArray lastObject];
    UIView *view = progressModel.progressView;
    
    [view removeFromSuperview];
    [self.progressArray removeLastObject];
    
    CGRect size = self.pointView.frame;
    size.origin.x -= view.frame.size.width + 2;
    self.pointView.frame = size;
}

- (float)allValue
{
    float value = 0.0f;
    
    for (PPProgressModel *progressModel in self.progressArray) {
        value += progressModel.progressTime;
    }
    
    return value;
}

#pragma mark -
- (PPProgressModel *)createNewProgressModel
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
    view.backgroundColor = [UIColor hexStringToColor:@"F65F0C"];
    [self addSubview:view];
    
    PPProgressModel *progressModel = [[PPProgressModel alloc] init];
    progressModel.progressView = view;
    
    return progressModel;
}

- (UIView *)pointView
{
    if (_pointView == nil) {
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
        _pointView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pointView];
    }
    
    return _pointView;
}

@end
