//
//  SLKMediaProcesserViewController.m
//  MediaStreamerDemo
//
//  Created by Think on 2016/11/22.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import "SLKMediaProcesserViewController.h"

@interface SLKMediaProcesserViewController () <SLKMediaMergerDelegate>

@property (nonatomic, strong) SLKMediaMerger *slkMediaMerger;
@property (nonatomic, strong) SLKMediaMaterialGroup *slkMediaMaterialGroup;
@property (nonatomic, strong) SLKMediaProduct* slkMediaProduct;

@end

@implementation SLKMediaProcesserViewController

+ (void)presentFromViewController:(UIViewController *)viewController
{
    [viewController presentViewController:[[SLKMediaProcesserViewController alloc] init] animated:YES completion:nil];
}

- (instancetype)init {
    self = [self initWithNibName:@"SLKMediaProcesserViewController" bundle:nil];
    if (self) {
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
    NSLog(@"SLKMediaProcesserViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slkMediaMerger = [[SLKMediaMerger alloc] init];
    self.slkMediaMerger.delegate = self;

    
    self.slkMediaMaterialGroup = [[SLKMediaMaterialGroup alloc] init];
    self.slkMediaProduct = [[SLKMediaProduct alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.slkMediaMerger stop];
    [self.slkMediaMerger terminate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startAction:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString* docPath1= [docDir stringByAppendingString:@"/ppy.mp4"];
    NSString* docPath2= [docDir stringByAppendingString:@"/ppy.mp4"];
    NSString* docPath3= [docDir stringByAppendingString:@"/ppy.mp4"];
    
//    NSString* docPath2= [[NSBundle mainBundle] pathForResource:@"slk" ofType:@"mp4"];
//    NSString *docPath4 = [[NSBundle mainBundle] pathForResource:@"ppy" ofType:@"mp3"];
//    NSString* docPath5= [docDir stringByAppendingString:@"/overlay.png"];
//    NSString* docPath6= [docDir stringByAppendingString:@"/overlay1.png"];


//    SLKMediaMaterial *slkMediaMaterial = [[SLKMediaMaterial alloc] init];
//    slkMediaMaterial.url = docPath1;
//    slkMediaMaterial.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_PNG;
//    slkMediaMaterial.startPos = 0;
//    slkMediaMaterial.endPos = 4*1000;

    SLKMediaMaterial *slkMediaMaterial1 = [[SLKMediaMaterial alloc] init];
    slkMediaMaterial1.url = docPath1;
    slkMediaMaterial1.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_VIDEO_AUDIO;
    slkMediaMaterial1.startPos = 0;
    slkMediaMaterial1.endPos = 10*1000;
    slkMediaMaterial1.weight = 1.0f;
    
    SLKMediaMaterial *slkMediaMaterial2 = [[SLKMediaMaterial alloc] init];
    slkMediaMaterial2.url = docPath2;
    slkMediaMaterial2.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_VIDEO_AUDIO;
    slkMediaMaterial2.startPos = 6*1000;
    slkMediaMaterial2.endPos = 10*1000;
    slkMediaMaterial2.weight = 1.0f;
    
    SLKMediaMaterial *slkMediaMaterial3 = [[SLKMediaMaterial alloc] init];
    slkMediaMaterial3.url = docPath3;
    slkMediaMaterial3.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_VIDEO_AUDIO;
    slkMediaMaterial3.startPos = 20*1000;
    slkMediaMaterial3.endPos = 24*1000;
    slkMediaMaterial3.weight = 1.0f;

    
//    SLKMediaMaterial *slkMediaMaterial4 = [[SLKMediaMaterial alloc] init];
//    slkMediaMaterial4.url = docPath4;
//    slkMediaMaterial4.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_AUDIO;
//    slkMediaMaterial4.startPos = 0;
//    slkMediaMaterial4.endPos = 10*1000;
//    slkMediaMaterial4.weight = 0.2f;
    
//    SLKMediaMaterial *slkMediaMaterial5 = [[SLKMediaMaterial alloc] init];
//    slkMediaMaterial5.url = docPath5;
//    slkMediaMaterial5.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_PNG;
//    slkMediaMaterial5.startPos = 0;
//    slkMediaMaterial5.endPos = 10*1000;
//    slkMediaMaterial5.weight = 1.0f;
//    slkMediaMaterial5.x = 0;
//    slkMediaMaterial5.y = 0;
    
//    SLKMediaMaterial *slkMediaMaterial6 = [[SLKMediaMaterial alloc] init];
//    slkMediaMaterial6.url = docPath6;
//    slkMediaMaterial6.slk_media_material_type = SLK_MEDIA_MATERIAL_TYPE_PNG;
//    slkMediaMaterial6.startPos = 10*1000;
//    slkMediaMaterial6.endPos = 12*1000;
//    slkMediaMaterial6.weight = 1.0f;
//    slkMediaMaterial6.x = -20;
//    slkMediaMaterial6.y = -20;
    
    [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial1];
    [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial2];
    [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial3];
//    [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial4];
//    [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial5];
//    [self.slkMediaMaterialGroup addMediaMaterial:slkMediaMaterial6];


    self.slkMediaProduct.url = [docDir stringByAppendingString:@"/product.mp4"];
    self.slkMediaProduct.hasVideo = YES;
    self.slkMediaProduct.videoSize = CGSizeMake(480,640);
    self.slkMediaProduct.hasAudio = YES;
    self.slkMediaProduct.bps = 2000;
    
    [self.slkMediaMerger initializeWithInputMaterialGroup:self.slkMediaMaterialGroup WithMergeAlgorithm:SLK_MEDIA_MERGE_ALGORITHM_TIMELINE WithOutputMediaProduct:self.slkMediaProduct];
    
    [self.slkMediaMaterialGroup removeMediaMaterial:slkMediaMaterial1];
    [self.slkMediaMaterialGroup removeMediaMaterial:slkMediaMaterial2];
    [self.slkMediaMaterialGroup removeMediaMaterial:slkMediaMaterial3];
    
//    [self.slkMediaMaterialGroup removeMediaMaterial:slkMediaMaterial4];
//    [self.slkMediaMaterialGroup removeMediaMaterial:slkMediaMaterial5];
//    [self.slkMediaMaterialGroup removeMediaMaterial:slkMediaMaterial6];

    
    [self.slkMediaMerger start];
}

- (IBAction)stopAction:(id)sender
{
    [self.slkMediaMerger stop];
    [self.slkMediaMerger terminate];
}

- (void)gotErrorWithErrorType:(int)errorType
{
    NSLog(@"gotErrorWithErrorType errorType:%d",errorType);
}

- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue
{
    if (infoType==SLK_MEDIA_PROCESSER_INFO_WRITE_TIMESTAMP) {
        NSLog(@"Write TimeStamp:%d",infoValue);
    }
}

- (void)didEnd
{
    NSLog(@"didEnd");
}

@end
