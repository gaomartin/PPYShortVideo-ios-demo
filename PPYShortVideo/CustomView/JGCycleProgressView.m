//
//  JGCycleProgressView.m
//  PPYShortVideo
//
//  Created by admin on 2016/11/10.
//  Copyright © 2016年 高小冻. All rights reserved.
//

#import "JGCycleProgressView.h"
#import "Masonry.h"
@interface JGCycleProgressView ()
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation JGCycleProgressView

-(void)initialize{
    self.backgroundColor = [UIColor clearColor];
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_lessThanOrEqualTo(CGSizeMake(100, 100));
    }];
    
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    [self drawCycleProgressBasedCenter:center];
}

- (void)drawCycleProgressBasedCenter:(CGPoint)aPoint
{
    CGPoint center = aPoint;
    CGFloat radius = 70;
    CGFloat startA = - M_PI_2;  //设置进度条起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //设置进度条终点位置
    
    //获取环形路径（画一个圆形，填充色透明，设置线框宽度为10，这样就获得了一个环形）
    _progressLayer = [CAShapeLayer layer];//创建一个track shape layer
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];  //填充色为无色
    _progressLayer.strokeColor = [[UIColor orangeColor] CGColor]; //指定path的渲染颜色,这里可以设置任意不透明颜色
    _progressLayer.opacity = 1; //背景颜色的透明度
    _progressLayer.lineCap = kCALineCapRound;//指定线的边缘是圆的
    _progressLayer.lineWidth = 10;//线的宽度
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];//上面说明过了用来构建圆形
    _progressLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    [self.layer addSublayer:_progressLayer];
    //    //生成渐变色
    //    CALayer *gradientLayer = [CALayer layer];
    
    //    //左侧渐变色
    //    CAGradientLayer *leftLayer = [CAGradientLayer layer];
    //    leftLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);    // 分段设置渐变色
    //    leftLayer.locations = @[@0.3, @0.9, @1];
    //    leftLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor greenColor].CGColor];
    //    [gradientLayer addSublayer:leftLayer];
    
    //    //右侧渐变色
    //    CAGradientLayer *rightLayer = [CAGradientLayer layer];
    //    rightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
    //    rightLayer.locations = @[@0.3, @0.9, @1];
    //    rightLayer.colors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor redColor].CGColor];
    //    [gradientLayer addSublayer:rightLayer];
    
    //    [gradientLayer setMask:_progressLayer]; //用progressLayer来截取渐变层
    //    [self.layer addSublayer:gradientLayer];
    
}


@end

