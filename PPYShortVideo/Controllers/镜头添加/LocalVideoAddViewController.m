//
//  LocalVideoAddViewController.m
//  PPYShortVideo
//
//  Created by bobzhang on 16/12/15.
//  Copyright © 2016年 PPTV. All rights reserved.
//

#import "LocalVideoAddViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumVideoInfo.h"
#import "LocalVideoCell.h"
#import "SelectVideoViewCell.h"
#import "XWDragCellCollectionView.h"

#define kItemCountInVideoListCell 4

@interface LocalVideoAddViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate, PPCollectionCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet XWDragCellCollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *albumVideoInfos;
@property (nonatomic, strong) NSMutableArray *selectVideoArray;

@end

@implementation LocalVideoAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _albumVideoInfos = [NSMutableArray array];
    _selectVideoArray = [NSMutableArray array];
    [self loadLocalVideo];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectVideoViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.shakeLevel = 3.0f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLocalVideo
{
    ALAssetsLibrary *library1 = [[ALAssetsLibrary alloc] init];
    [library1 enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    AlbumVideoInfo *videoInfo = [[AlbumVideoInfo alloc] init];
                    videoInfo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                    //                    videoInfo.videoURL = [result valueForProperty:ALAssetPropertyAssetURL];
                    videoInfo.videoURL = result.defaultRepresentation.url;
                    videoInfo.duration = [result valueForProperty:ALAssetPropertyDuration];
                    videoInfo.name = [result valueForProperty:ALAssetPropertyDate];
                    videoInfo.size = result.defaultRepresentation.size; //Bytes
                    videoInfo.format = [result.defaultRepresentation.filename pathExtension];
                    [_albumVideoInfos addObject:videoInfo];
                }
            }];
        } else {
            //没有更多的group时，即可认为已经加载完成。
            NSLog(@"after load, the total alumvideo count is %zd",_albumVideoInfos.count);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_selectVideoArray addObject:_albumVideoInfos];//test
                [self.collectionView reloadData];
            });
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed.");
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return [self.albumVideoInfos count] / kItemCountInVideoListCell + ([self.albumVideoInfos count] % kItemCountInVideoListCell ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LocalVideoCellIdentifier";
    LocalVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LocalVideoCell" owner:nil options:nil] objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSInteger leftCount = [self.albumVideoInfos count] - indexPath.row * kItemCountInVideoListCell;
    NSRange range = NSMakeRange(indexPath.row * kItemCountInVideoListCell, ((leftCount > kItemCountInVideoListCell) || (leftCount < 0)) ? kItemCountInVideoListCell : leftCount);
    NSArray *temp = [self.albumVideoInfos subarrayWithRange:range];
    [cell refreshCellWithSourceList:temp];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - <XWDragCellCollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.selectVideoArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sec = _selectVideoArray[section];
    return sec.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectVideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.delegate = self;
    AlbumVideoInfo *videoInfo = _selectVideoArray[indexPath.section][indexPath.item];
    cell.imageView.image = videoInfo.thumbnail;
    return cell;
}

- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView
{
    return _selectVideoArray;
}

#pragma mark - <XWDragCellCollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumVideoInfo *videoInfo = _selectVideoArray[indexPath.section][indexPath.item];
    NSLog(@"点击了%@",videoInfo.name);
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray
{
    _selectVideoArray = [NSMutableArray arrayWithArray:newDataArray];
}

#pragma mark - PPCollectionCellDelegate
- (void)deleteCell:(SelectVideoViewCell *)cell
{
    for (AlbumVideoInfo *videoInfo in _selectVideoArray[0]) {
        if (cell.imageView.image == videoInfo.thumbnail) {
            [_selectVideoArray[0] removeObject:videoInfo];
            [self.collectionView reloadData];
            return;
        }
    }
}

@end
