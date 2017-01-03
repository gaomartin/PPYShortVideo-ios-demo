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

#define kItemCountInVideoListCell 4

@interface LocalVideoAddViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate, PPCollectionCellDelegate>

@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, weak) IBOutlet UICollectionView *localCollectionView;
@property (nonatomic, weak) IBOutlet XWDragCellCollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *localVideoArray;
@property (nonatomic, strong) NSMutableArray *selectVideoArray;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLocalVideo
{
    NSMutableArray *array = [NSMutableArray array];
    ALAssetsLibrary *library1 = [[ALAssetsLibrary alloc] init];
    [library1 enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    BZVideoInfo *info = [[BZVideoInfo alloc] init];
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
                [self.localCollectionView reloadData];
                
                [self.selectVideoArray addObject:array];//test
                [self.collectionView reloadData];
            });
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"load LocalVideo Failed.");
    }];
}

#pragma mark - button actions
- (IBAction)cancelBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraBtnClicked:(id)sender
{
    
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
            [self.selectVideoArray[0] removeObject:videoInfo];
            [self.collectionView reloadData];
            return;
        }
    }
}

@end
