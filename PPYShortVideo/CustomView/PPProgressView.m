//
//  PPProgressView.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/14.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "PPProgressView.h"

@interface PPProgressView ()

@property (nonatomic, assign) float curValue;
@property (nonatomic, strong) UIImageView *pointImageView;

@end


@implementation PPProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    
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

@end
