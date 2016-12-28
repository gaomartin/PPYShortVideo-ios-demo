//
//  BZVideoCutViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/23.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "BZVideoCutViewController.h"
#import "PlayerView.h"
#import "BZVideoInfo.h"
#import "NSString+time.h"

#define KMAX_PRE_IMAGEVIEW      7
#define KMIN_DISTANCE           5

@interface BZVideoCutViewController () <SLKMediaInfoDelegate>

@property (nonatomic, strong) SLKMediaInfo *slkMediaInfo;

@property (nonatomic, weak) IBOutlet PlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIView *infoView;
@property (nonatomic, weak) IBOutlet UIView *preView;
@property (nonatomic, weak) IBOutlet UILabel *startPosLabel;
@property (nonatomic, weak) IBOutlet UILabel *endPosLabel;

@property (nonatomic, assign) NSInteger thumbnailIndex;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *imageDataArray;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property  CGPoint beginPoint;

@end

@implementation BZVideoCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.playerView.playerURL = self.videoInfo.path;
    self.startPosLabel.text = [NSString timeformatFromSeconds: (NSInteger)self.videoInfo.startPos/1000];
    self.endPosLabel.text = [NSString timeformatFromSeconds: (NSInteger) self.videoInfo.endPos/1000];
    
    self.imageViewArray = [NSMutableArray array];
    self.imageDataArray = [NSMutableArray array];
    
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
    [self.slkMediaInfo quit];
    [self.slkMediaInfo terminate];
    self.playerView = nil;
    
    [self.infoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmBtnClicked:(id)sender
{
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

- (void)requestPreImage
{
    self.thumbnailIndex = 0;
    if (!self.slkMediaInfo) {
        self.slkMediaInfo = [[SLKMediaInfo alloc] init];
    }
    self.slkMediaInfo.delegate = self;
    [self.slkMediaInfo initialize];
    [self.slkMediaInfo setThumbnailsOptionWithWidth:(KMainScreenWidth - 40)/KMAX_PRE_IMAGEVIEW
                                         WithHeight:self.preView.frame.size.height
                                 WithThumbnailCount:KMAX_PRE_IMAGEVIEW];
    [self.slkMediaInfo loadAsync:self.videoInfo.path];
}

- (void)showPreImage
{
    for (int i=0; i<KMAX_PRE_IMAGEVIEW; i++) {
        UIImageView *imageView = [self.imageViewArray objectAtIndex:i];
        NSData *imageData = [self.imageDataArray objectAtIndex:i];
        imageView.image = [UIImage imageWithData:imageData];
    }
}

- (void)addCutEffectView
{
    //两边各空20, 中间的width-40作为总长度的进度标准
    CGFloat length = KMainScreenWidth - 40;
    CGFloat xOriginLeft = self.videoInfo.startPos / self.videoInfo.total * length;
    CGFloat xOriginRight = self.videoInfo.endPos / self.videoInfo.total * length;
    
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
        
        self.leftView.center = CGPointMake(centerX, centerY);
        
        self.videoInfo.startPos = (centerX - self.leftView.frame.size.width / 2) * self.videoInfo.total / length ;
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
        
        self.rightView.center = CGPointMake(centerX, centerY);
        self.videoInfo.endPos = (centerX - self.rightView.frame.size.width / 2) * self.videoInfo.total / length ;
    }
    
    self.startPosLabel.text = [NSString timeformatFromSeconds: (NSInteger)self.videoInfo.startPos/1000];
    self.endPosLabel.text = [NSString timeformatFromSeconds: (NSInteger) self.videoInfo.endPos/1000];
}

#pragma mark - SLKMediaInfoDelegate

- (void)gotMediaDetailInfoWithDuration:(int64_t)duration WithWidth:(int)width WithHeight:(int)height
{
    NSLog(@"gotMediaDetailInfoWithDuration Duration:%lld Width:%d Height:%d",duration, width, height);
}

- (void)gotThumbnailWithCVPixelBuffer:(CVPixelBufferRef)outputThumbnailData
{
    NSLog(@"gotThumbnailWithCVPixelBuffer");
    
    if (outputThumbnailData==nil) return ;
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:outputThumbnailData];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(outputThumbnailData),
                                                 CVPixelBufferGetHeight(outputThumbnailData))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    NSData* imageData = UIImageJPEGRepresentation(uiImage,0.5f);
    [self.imageDataArray addObject:imageData];
   
    CVPixelBufferRelease(outputThumbnailData);
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
    [self showPreImage];
}


@end
