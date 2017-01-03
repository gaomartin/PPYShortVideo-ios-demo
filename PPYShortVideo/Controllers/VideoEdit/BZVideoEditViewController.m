//
//  BZVideoEditViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/23.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "BZVideoEditViewController.h"
#import "JGCycleProgressView.h"
#import "PlayerView.h"
#import "Masonry.h"

#import "BZVideoInfo.h"
#import "SelectVideoViewCell.h"
#import "XWDragCellCollectionView.h"
#import "BZVideoCutViewController.h"
#import "RecordController.h"
@interface BZVideoEditViewController ()<PPCollectionCellDelegate>

@property (strong, nonatomic) IBOutlet PlayerView *playerView;
@property (strong, nonatomic) JGCycleProgressView *progressView;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, weak) IBOutlet XWDragCellCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, strong) BZVideoInfo *selectInfo;

@end

@implementation BZVideoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectVideoViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.shakeLevel = 3.0f;
    
    self.infoArray = [NSMutableArray array];
    [self.infoArray addObject:[BZEditVideoInfo shareInstance].editVideoArry];
    
    [self setSelectVideoWithIndex:0];
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playerView.playerURL = [BZEditVideoInfo shareInstance].mediaProduct.url;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectVideoWithIndex:(NSInteger)index
{
    NSArray *array = [self.infoArray objectAtIndex:0];
    
    for (int i=0; i<[array count]; i++) {
        BZVideoInfo *videoInfo = [array objectAtIndex:i];
        if (i==index) {
            videoInfo.isSelected = YES;
            self.selectInfo = videoInfo;
        } else {
            videoInfo.isSelected = NO;
        }
    }
}

- (IBAction)backBtnClicked:(id)sender
{
    self.playerView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmBtnClicked:(id)sender
{
    self.playerView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)videoCutBtnClicked:(id)sender
{
    BZVideoCutViewController *cut = [[BZVideoCutViewController alloc] init];
    
    //这里不能直接对象赋值, 不然cut页面取消修改, 也会保存修改的值.
    BZVideoInfo *info = [[BZVideoInfo alloc] init];
    info.path = self.selectInfo.path;
    info.startPos = self.selectInfo.startPos;
    info.endPos = self.selectInfo.endPos;
    info.total = self.selectInfo.total;
    cut.videoInfo = info;
    
    [self.navigationController pushViewController:cut animated:YES];
    [self.playerView stop];
}

#pragma mark - <XWDragCellCollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.infoArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sec = self.infoArray[section];
    return sec.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectVideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.delegate = self;
    BZVideoInfo *videoInfo = self.infoArray[indexPath.section][indexPath.item];
    [cell refreshCellWithInfo:videoInfo];
    
    return cell;
}

- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView
{
    return self.infoArray;
}

#pragma mark - <XWDragCellCollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了%zd",indexPath.item);
    [self setSelectVideoWithIndex:indexPath.item];
    [self.collectionView reloadData];
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    self.infoArray = [NSMutableArray arrayWithArray:newDataArray];
}

#pragma mark - PPCollectionCellDelegate
- (void)deleteCell:(SelectVideoViewCell *)cell
{
    for (BZVideoInfo *videoInfo in self.infoArray[0]) {
        if ([cell.fileIdentifier isEqualToString: videoInfo.path]) {
            [self.infoArray[0] removeObject:videoInfo];
            [self refreshCollectionView];
            return;
        }
    }
}

- (void)refreshCollectionView
{
    NSArray *videoArray = self.infoArray[0];
    
    if ([videoArray count] == 0) {
        [self allVideoHasDelete];
        return;
    }
    
    BOOL isHaveSelectVideo = NO;
    
    for (BZVideoInfo *videoInfo in self.infoArray[0]) {
        if (videoInfo.isSelected) {
            isHaveSelectVideo = YES;
        }
    }
    
    if (!isHaveSelectVideo) {
        BZVideoInfo *videoInfo = videoArray[0];
        videoInfo.isSelected = YES;
        self.selectInfo = videoInfo;
    }
    
    [self.collectionView reloadData];
}


- (void)allVideoHasDelete
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你已删除所有镜头, 是否重新开始录制？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"重新录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];//录制页面
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];//返回首页
    }];
    
    [alert addAction:OK];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:NO completion:nil];
}
@end
