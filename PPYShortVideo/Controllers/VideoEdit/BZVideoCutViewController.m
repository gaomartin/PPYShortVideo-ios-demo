//
//  BZVideoCutViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/23.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "BZVideoCutViewController.h"
#import "BZVideoInfo.h"
#import "NSString+time.h"

#define KMAX_PRE_IMAGEVIEW      7
#define KMIN_DISTANCE           5

@interface BZVideoCutViewController () <PPYThumbnailInfoDelegate>

@property (nonatomic, strong) PPYThumbnailInfo *thumbnailInfo;

@property (nonatomic, weak) IBOutlet LocalPlayerView *localPlayerView;
@property (nonatomic, weak) IBOutlet UIView *infoView;
@property (nonatomic, weak) IBOutlet UIView *preView;
@property (nonatomic, weak) IBOutlet UILabel *startPosLabel;
@property (nonatomic, weak) IBOutlet UILabel *endPosLabel;

@property (nonatomic, assign) NSInteger thumbnailIndex;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *leftBackgroudView;
@property (nonatomic, strong) UIView *rightBackgroudView;
@property  CGPoint beginPoint;

@end

@implementation BZVideoCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSMutableArray *pathArray = [NSMutableArray array];
    [pathArray addObject:self.videoInfo.path];
    self.localPlayerView.filePaths = pathArray;
    
    self.startPosLabel.text = [NSString timeformatFromSeconds: (NSInteger)self.videoInfo.startPos/1000];
    self.endPosLabel.text = [NSString timeformatFromSeconds: (NSInteger) self.videoInfo.endPos/1000];
    
    self.imageViewArray = [NSMutableArray array];
    
    [self createPreImageView];
    [self requestPreImage];
    [self addCutEffectView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"BZVideoCutViewController dealloc");
    [self.thumbnailInfo quit];
    [self.thumbnailInfo terminate];
    
    [self.localPlayerView clearCache];
    self.localPlayerView = nil;
    [self.infoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmBtnClicked:(id)sender
{
    for (BZVideoInfo *info in [BZEditVideoInfo shareInstance].editVideoArry) {
        if ([info.path isEqualToString:self.videoInfo.path]) {
            info.startPos = self.videoInfo.startPos;
            info.endPos = self.videoInfo.endPos;
        }
    }
    
    if ([BZEditVideoInfo shareInstance].editVideoType == BZEditVideoType_FromAddLocal) {
        [[BZEditVideoInfo shareInstance].editVideoArry addObject:self.videoInfo];
        
        for (BZVideoInfo *info in [BZEditVideoInfo shareInstance].editVideoArry) {
            if ([info.path isEqualToString:self.videoInfo.path]) {
                info.isAddVideo = YES;
            }
        }
        for (BZVideoInfo *info in [BZEditVideoInfo shareInstance].localEditVideoArry) {
            if ([info.path isEqualToString:self.videoInfo.path]) {
                info.isAddVideo = YES;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddVideoSuccessNotificatin object:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createPreImageView
{
    for (int i=0; i<KMAX_PRE_IMAGEVIEW; i++) {
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.backgroundColor = [UIColor clearColor];
        imageview.frame = CGRectMake((KMainScreenWidth - 40)/KMAX_PRE_IMAGEVIEW *i, 0, (KMainScreenWidth - 40)/KMAX_PRE_IMAGEVIEW, self.preView.frame.size.height);
        imageview.tag = i;
        [self.preView addSubview:imageview];
        [self.imageViewArray addObject:imageview];
    }
}

- (void)showPreImageWithData:(NSData *)imageData
{
    UIImageView *imageView = [self.imageViewArray objectAtIndex:self.thumbnailIndex++];
    imageView.image = [UIImage imageWithData:imageData];
}

- (void)requestPreImage
{
    self.thumbnailIndex = 0;
    if (!self.thumbnailInfo) {
        self.thumbnailInfo = [[PPYThumbnailInfo alloc] init];
    }
    self.thumbnailInfo.delegate = self;
    [self.thumbnailInfo setThumbnailsOptionWithWidth:(KMainScreenWidth - 40)/KMAX_PRE_IMAGEVIEW
                                         WithHeight:self.preView.frame.size.height
                                 WithThumbnailCount:KMAX_PRE_IMAGEVIEW];
    [self.thumbnailInfo loadAsync:self.videoInfo.path];
}

- (void)addCutEffectView
{
    //两边各空20, 中间的width-40作为总长度的进度标准
    CGFloat length = KMainScreenWidth - 40;
    CGFloat xOriginLeft = self.videoInfo.startPos / self.videoInfo.total * length;
    CGFloat xOriginRight = self.videoInfo.endPos / self.videoInfo.total * length;
    
    self.leftBackgroudView = [[UIView alloc] init];
    self.leftBackgroudView.backgroundColor = [UIColor blackColor];
    self.leftBackgroudView.alpha = 0.5;
    self.leftBackgroudView.frame = CGRectMake(0, 0, xOriginLeft, self.preView.frame.size.height);
    [self.preView addSubview:self.leftBackgroudView];
    
    self.rightBackgroudView = [[UIView alloc] init];
    self.rightBackgroudView.backgroundColor = [UIColor blackColor];
    self.rightBackgroudView.alpha = 0.5;
    self.rightBackgroudView.frame = CGRectMake(xOriginRight, 0, length - xOriginRight, self.preView.frame.size.height);
    [self.preView addSubview:self.rightBackgroudView];
    
    UIImageView *left = [[UIImageView alloc] init];
    left.image = [UIImage imageNamed:@"组-40"];
    left.frame = CGRectMake(0, 0, 40, 84);
    [left setContentMode:UIViewContentModeCenter];
    
    self.leftView = [[UIView alloc] initWithFrame:CGRectMake(xOriginLeft, 45, 40, 84)];
    [self.leftView addSubview:left];
    [self.infoView addSubview:self.leftView];
    
    UIImageView *right = [[UIImageView alloc] init];
    right.image = [UIImage imageNamed:@"组-41"];
    right.frame = CGRectMake(0, 0, 40, 84);
    [right setContentMode:UIViewContentModeCenter];
    
    self.rightView = [[UIView alloc] initWithFrame:CGRectMake(xOriginRight, 45, 40, 84)];
    [self.rightView addSubview:right];
    [self.infoView addSubview:self.rightView];
}

#pragma mark - UIEvent
//拖动事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (touch.view != self.leftView && touch.view.superview != self.leftView &&
        touch.view != self.rightView && touch.view.superview != self.rightView) {
        return;
    }
    
    if (touch.view == self.leftView) {
        self.beginPoint = [touch locationInView:self.leftView];
    } else if (touch.view == self.rightView) {
        self.beginPoint = [touch locationInView:self.rightView];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (touch.view != self.leftView && touch.view != self.rightView) {
        return;
    }
    
    //两边各空20, 中间的width-40作为总长度的进度标准
    CGFloat length = KMainScreenWidth - 40;
    
    if (touch.view == self.leftView) {
        CGPoint nowPoint = [touch locationInView:self.leftView];
        
        float offsetX = nowPoint.x - self.beginPoint.x;
        
        CGFloat centerX = self.leftView.center.x + offsetX;
        CGFloat centerY = self.leftView.center.y;
        
        if (centerX < self.leftView.frame.size.width / 2) {
            centerX = self.leftView.frame.size.width / 2;
        } else if (centerX > self.rightView.center.x - KMIN_DISTANCE){
            centerX = self.rightView.center.x - KMIN_DISTANCE;
        }
        //滑块
        self.leftView.center = CGPointMake(centerX, centerY);
        //时间
        self.videoInfo.startPos = (centerX - self.leftView.frame.size.width / 2) * self.videoInfo.total / length ;
        self.startPosLabel.text = [NSString timeformatFromSeconds: (NSInteger)self.videoInfo.startPos/1000];
        //阴影
        CGRect frame = self.leftBackgroudView.frame;
        frame.size.width = centerX - 20;
        self.leftBackgroudView.frame = frame;
        
        //[self.playerView seekToPostion:self.videoInfo.startPos];
        [self.localPlayerView seekToPostion:self.videoInfo.startPos];
    } else if (touch.view == self.rightView) {
        CGPoint nowPoint = [touch locationInView:self.rightView];
        
        float offsetX = nowPoint.x - self.beginPoint.x;
        
        CGFloat centerX = self.rightView.center.x + offsetX;
        CGFloat centerY = self.rightView.center.y;
        
        if (centerX > self.view.frame.size.width - self.rightView.frame.size.width / 2) {
            centerX = self.view.frame.size.width - self.rightView.frame.size.width / 2;
        } else if (centerX < self.leftView.center.x + KMIN_DISTANCE){
            centerX = self.leftView.center.x + KMIN_DISTANCE;
        }
        //滑块
        self.rightView.center = CGPointMake(centerX, centerY);
        //时间
        self.videoInfo.endPos = (centerX - self.rightView.frame.size.width / 2) * self.videoInfo.total / length ;
        self.endPosLabel.text = [NSString timeformatFromSeconds: (NSInteger) self.videoInfo.endPos/1000];
        //阴影
        CGRect frame = self.rightBackgroudView.frame;
        frame.origin.x = centerX - 20;
        frame.size.width = KMainScreenWidth - centerX - 20;
        self.rightBackgroudView.frame = frame;
        
        //TODO:右边滑块拖动不改变视频进度条
        //[self.playerView seekToPostion:self.videoInfo.endPos];
    }
}

#pragma mark - SLKMediaInfoDelegate

- (void)gotMediaDetailInfoWithDuration:(int64_t)duration WithWidth:(int)width WithHeight:(int)height
{
    NSLog(@"gotMediaDetailInfoWithDuration Duration:%lld Width:%d Height:%d",duration, width, height);
}

- (void)gotThumbnailWithImageData:(NSData *)imageData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [self.imageViewArray objectAtIndex:self.thumbnailIndex++];
        imageView.image = [UIImage imageWithData:imageData];
    });
}

- (void)gotErrorWithErrorType:(int)errorType
{
    NSLog(@"gotErrorWithErrorType errorType:%d",errorType);
}

- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue
{
    
}

- (void)didEnd
{
    NSLog(@"didEnd");
}


@end
