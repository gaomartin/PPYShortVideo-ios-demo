//
//  SLKMediaInfoViewController.m
//  MediaStreamerDemo
//
//  Created by Think on 2016/11/29.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import "SLKMediaInfoViewController.h"

@interface SLKMediaInfoViewController () <SLKMediaInfoDelegate>
{
    int mThumbnailIndex;
}

@property (nonatomic, strong) SLKMediaInfo *slkMediaInfo;

@end

@implementation SLKMediaInfoViewController

+ (void)presentFromViewController:(UIViewController *)viewController
{
    [viewController presentViewController:[[SLKMediaInfoViewController alloc] init] animated:YES completion:nil];
}

- (instancetype)init {
    self = [self initWithNibName:@"SLKMediaInfoViewController" bundle:nil];
    if (self) {
        mThumbnailIndex = -1;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"SLKMediaInfoViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slkMediaInfo = [[SLKMediaInfo alloc] init];
    self.slkMediaInfo.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.slkMediaInfo quit];
    [self.slkMediaInfo terminate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startAction:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString* docPath1= [docDir stringByAppendingString:@"/ppy.mp4"];
    
    [self.slkMediaInfo initialize];
    [self.slkMediaInfo setThumbnailsOptionWithWidth:160 WithHeight:160 WithThumbnailCount:8];
    [self.slkMediaInfo loadAsync:docPath1];
}

- (IBAction)stopAction:(id)sender
{
    [self.slkMediaInfo quit];
    [self.slkMediaInfo terminate];
}

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
    mThumbnailIndex++;
    NSString* docPath2= [docDir stringByAppendingFormat:@"/ppy_%d,jpg",mThumbnailIndex];
    
    [imageData writeToFile:docPath2 atomically:NO];
    
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
