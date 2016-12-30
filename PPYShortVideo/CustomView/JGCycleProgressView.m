//
//  JGCycleProgressView.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "JGCycleProgressView.h"
#import "Masonry.h"

#define kRadius 30
#define kBorderWidth 5

@interface JGCycleProgressView ()
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation JGCycleProgressView

-(void)initialize{
    self.backgroundColor = [UIColor clearColor];
    
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor blackColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.layer.cornerRadius = kRadius;
    self.label.layer.masksToBounds = YES;
    self.label.layer.borderWidth = kBorderWidth;
    self.label.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.backgroundColor = [UIColor clearColor];
    self.detailLabel.textColor = [UIColor whiteColor];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.label];
    [self addSubview:self.detailLabel];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kRadius * 2, kRadius * 2));
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kRadius * 4, kRadius * 2));
        make.centerX.mas_equalTo(self.bounds.origin.x);
        make.bottom.equalTo(self.mas_bottom).with.offset(30);
    }];
    self.label.text = @"0%";
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initialize];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self initialize];
    }
    return self;
}

- (void)drawProgress:(CGFloat )progress
{
    _progress = progress;
    _progressLayer.opacity = 0;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    [self drawCycleProgressBasedCenter:center];
}

- (void)drawCycleProgressBasedCenter:(CGPoint)aPoint
{
    CGPoint center = aPoint;
    CGFloat radius = kRadius - kBorderWidth/2;
    CGFloat startA = - M_PI_2;  //设置进度条起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //设置进度条终点位置
    
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    _progressLayer = [CAShapeLayer layer];//创建一个track shape layer
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    _progressLayer.strokeColor = [[UIColor orangeColor] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    _progressLayer.opacity = 1; //背景颜色的透明度
    _progressLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
    _progressLayer.lineWidth = kBorderWidth;//线的宽度
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];//上面说明过了用来构建圆形
    _progressLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.layer addSublayer:_progressLayer];
}

@end

