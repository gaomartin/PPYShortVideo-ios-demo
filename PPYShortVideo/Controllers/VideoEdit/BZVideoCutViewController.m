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

#define KMAX_PRE_IMAGEVIEW 7

@interface BZVideoCutViewController () <SLKMediaInfoDelegate>

@property (nonatomic, strong) SLKMediaInfo *slkMediaInfo;

@property (strong, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (weak, nonatomic) IBOutlet UILabel *startPosLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPosLabel;

@property (nonatomic,assign) NSInteger thumbnailIndex;
@property (strong, nonatomic) NSMutableArray *imageViewArray;

@end

@implementation BZVideoCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.playerView.playerURL = self.videoInfo.path;
    self.startPosLabel.text = [NSString timeformatFromSeconds: (NSInteger)self.videoInfo.startPos/1000];
    self.endPosLabel.text = [NSString timeformatFromSeconds: (NSInteger) self.videoInfo.endPos/1000];
    
    self.imageViewArray = [NSMutableArray array];
    
    [self createPreImageView];
    [self requestPreImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        imageview.frame = CGRectMake(self.preView.frame.size.width/KMAX_PRE_IMAGEVIEW *i, 0, self.preView.frame.size.width/KMAX_PRE_IMAGEVIEW, self.preView.frame.size.height);
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
    [self.slkMediaInfo setThumbnailsOptionWithWidth:self.preView.frame.size.width/KMAX_PRE_IMAGEVIEW
                                         WithHeight:self.preView.frame.size.height
                                 WithThumbnailCount:KMAX_PRE_IMAGEVIEW];
    [self.slkMediaInfo loadAsync:self.videoInfo.path];
}

- (void)showPreImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    for (int i=0; i<KMAX_PRE_IMAGEVIEW; i++) {
        UIImageView *imageView = [self.imageViewArray objectAtIndex:i];
        NSString* docPath= [docDir stringByAppendingFormat:@"/ppy_%d.png",i];
        NSData *imageData = [NSData dataWithContentsOfFile:docPath];
        UIImage *image = [UIImage imageWithData:imageData];
        imageView.image = image;
    }
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
    
    NSData* imageData = UIImageJPEGRepresentation(uiImage,1.0f);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString* docPath= [docDir stringByAppendingFormat:@"/ppy_%d.png",self.thumbnailIndex++];
    NSLog(@"docPath = %@",docPath);
    [imageData writeToFile:docPath atomically:NO];
    
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
