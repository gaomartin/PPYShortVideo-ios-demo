//
//  LocalVideoAddViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/15.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "LocalVideoAddViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LocalVideoCell.h"
#import "SelectVideoViewCell.h"
#import "XWDragCellCollectionView.h"
#import "BZVideoCutViewController.h"

@interface LocalVideoAddViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate, PPCollectionCellDelegate>

@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, weak) IBOutlet UICollectionView *localCollectionView;
@property (nonatomic, weak) IBOutlet XWDragCellCollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *videoNumLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSMutableArray *localVideoArray;
@property (nonatomic, strong) NSMutableArray *selectVideoArray;
@property (nonatomic, strong) BZVideoInfo *deleteVideoInfo;

@end

@implementation LocalVideoAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.localVideoArray = [NSMutableArray array];
    self.selectVideoArray = [NSMutableArray array];
    [self loadLocalVideo];
    
    [self.localCollectionView registerNib:[UINib nibWithNibName:@"LocalVideoCell" bundle:nil] forCellWithReuseIdentifier:@"LocalCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectVideoViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.shakeLevel = 3.0f;
    
    [BZEditVideoInfo shareInstance].editVideoType = BZEditVideoType_FromAddLocal;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVideoCollectionView) name:kAddVideoSuccessNotificatin object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLocalVideo
{
    NSMutableArray *array = [NSMutableArray array];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    BZVideoInfo *info = [[BZVideoInfo alloc] init];
                    //videoInfo.videoURL = [result valueForProperty:ALAssetPropertyAssetURL];
                    info.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                    info.path = [NSString stringWithFormat:@"%@", result.defaultRepresentation.url];;
                    info.startPos = 0;
                    NSNumber *duration = [result valueForProperty:ALAssetPropertyDuration];
                    
                    info.endPos = [duration doubleValue] * 1000;
                    info.total = [duration doubleValue] * 1000;
                    [array addObject:info];
                }
            }];
        } else {
            //没有更多的group时，即可认为已经加载完成。
            NSLog(@"after load, the total alumvideo count is %zd",array.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.localVideoArray addObject:array];
                [BZEditVideoInfo shareInstance].localEditVideoArry = [NSMutableArray arrayWithArray:array];
                [self.localCollectionView reloadData];
            });
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"load LocalVideo Failed.");
    }];
}

- (void)refreshVideoCollectionView
{
    NSInteger videoNum = [[BZEditVideoInfo shareInstance].editVideoArry count];
    self.videoNumLabel.text = [NSString stringWithFormat:@"%zd", videoNum];
    [self.localCollectionView reloadData];
    
    [self.selectVideoArray removeAllObjects];
    [self.selectVideoArray addObject:[BZEditVideoInfo shareInstance].editVideoArry];
    [self.collectionView reloadData];
}

- (void)presentMessageView
{
    if (!self.messageLabel) {
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, KMainScreenWidth, 25)];
        self.messageLabel.backgroundColor = [UIColor orangeColor];
        self.messageLabel.text = @"  至少选择一段视频";
        self.messageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.font = [UIFont systemFontOfSize:12.f];
        [self.view addSubview:self.messageLabel];
        
        [self performSelector:@selector(removeMessageView) withObject:nil afterDelay:3.0f];
    }
}

- (void)removeMessageView
{
    if (self.messageLabel) {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
    }
}

#pragma mark - button actions
- (IBAction)cancelBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cameraBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishBtnClicked:(id)sender
{
    NSInteger videoNum = [[BZEditVideoInfo shareInstance].editVideoArry count];
    if (videoNum == 0) {
        [self presentMessageView];
    }
}

#pragma mark - <XWDragCellCollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.localCollectionView) {
        return [self.localVideoArray count];
    } else {
        return [self.selectVideoArray count];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (collectionView == self.localCollectionView) {
        NSArray *sec = self.localVideoArray[section];
        count = sec.count;
    } else {
        NSArray *sec = self.selectVideoArray[section];
        count = sec.count;
    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.localCollectionView) {
        LocalVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell" forIndexPath:indexPath];
        BZVideoInfo *videoInfo = self.localVideoArray[indexPath.section][indexPath.item];
        [cell refreshCellWithInfo:videoInfo];
        
        return cell;
    } else {
        SelectVideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.delegate = self;
        BZVideoInfo *videoInfo = self.selectVideoArray[indexPath.section][indexPath.item];
        [cell refreshCellWithInfo:videoInfo];
        
        return cell;
    }
}

- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView
{
    return self.selectVideoArray;
}

#pragma mark - <XWDragCellCollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.localCollectionView) {
        BZVideoInfo *videoInfo = self.localVideoArray[indexPath.section][indexPath.item];
        NSLog(@"local点击了%f",videoInfo.total);
        BZVideoCutViewController *cut = [[BZVideoCutViewController alloc] init];
        
        //这里不能直接对象赋值, 不然cut页面取消修改, 也会保存修改的值.
        BZVideoInfo *info = [[BZVideoInfo alloc] init];
        info.path = videoInfo.path;
        info.startPos = videoInfo.startPos;
        info.endPos = videoInfo.endPos;
        info.total = videoInfo.total;
        
        cut.videoInfo = info;
        [self.navigationController pushViewController:cut animated:YES];
    } else {
        BZVideoInfo *videoInfo = self.selectVideoArray[indexPath.section][indexPath.item];
        NSLog(@"点击了%f",videoInfo.total);
    }
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    self.selectVideoArray = [NSMutableArray arrayWithArray:newDataArray];
}

#pragma mark - PPCollectionCellDelegate
- (void)deleteCell:(SelectVideoViewCell *)cell
{
    for (BZVideoInfo *videoInfo in self.selectVideoArray[0]) {
        if ([cell.fileIdentifier isEqualToString: videoInfo.path]) {
            
            for (BZVideoInfo *info in self.localVideoArray[0]) {
                if ([info.path isEqualToString:videoInfo.path]) {
                    info.isAddVideo = NO;
                }
            }
            
            [self.selectVideoArray[0] removeObject:videoInfo];
            [self refreshVideoCollectionView];
            return;
        }
    }
}

@end
