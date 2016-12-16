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
#import "UICollectionView+Draggable.h"
#import "SelectVideoViewCell.h"

#define kItemCountInVideoListCell 4

@interface LocalVideoAddViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UICollectionViewDataSource_Draggable,UICollectionViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *albumVideoInfos;
@property (nonatomic, strong) NSMutableArray *selectVideoArray;
@property (nonatomic, assign) BOOL isDraging;

@end

@implementation LocalVideoAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _albumVideoInfos = [NSMutableArray array];
    _selectVideoArray = [NSMutableArray array];
    [self loadLocalVideo];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectVideoViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
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

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.selectVideoArray count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.selectVideoArray objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectVideoViewCell *cell = (SelectVideoViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSMutableArray *data = [self.selectVideoArray objectAtIndex:indexPath.section];
    AlbumVideoInfo *videoInfo = [data objectAtIndex:indexPath.row];
    cell.imageView.image = videoInfo.thumbnail;
    
    if (_isDraging) {
        [self shakeWithCell:cell];
    } else {
        [self stopShakeWithCell:cell];
    }
    
    return cell;
}

- (void)shakeWithCell:(SelectVideoViewCell *)cell
{
    NSLog(@"shake");
    srand([[NSDate date] timeIntervalSince1970]);
    float rand=(float)random();
    CFTimeInterval t=rand*0.0000000001;
    
    [UIView animateWithDuration:0.1 delay:t options:0  animations:^
     {
         cell.transform=CGAffineTransformMakeRotation(-0.05);
     } completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
          {
              cell.transform=CGAffineTransformMakeRotation(0.05);
          } completion:^(BOOL finished) {}];
     }];
}

-(void)stopShakeWithCell:(SelectVideoViewCell *)cell
{
    NSLog(@"stop shake");
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         cell.transform=CGAffineTransformIdentity;
     } completion:^(BOOL finished) {}];
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didLongpressOnItemAtIndexPath:(NSIndexPath *)indexPath;
{
    _isDraging = YES;
    [collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    _isDraging = NO;
    [self performSelector:@selector(reloadDataWith:) withObject:collectionView afterDelay:0.5];
}

- (void)reloadDataWith:(UICollectionView *)collectionView
{
    [collectionView reloadData];
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *data1 = [self.selectVideoArray objectAtIndex:fromIndexPath.section];
    NSMutableArray *data2 = [self.selectVideoArray objectAtIndex:toIndexPath.section];
    NSString *index = [data1 objectAtIndex:fromIndexPath.item];
    
    [data1 removeObjectAtIndex:fromIndexPath.item];
    [data2 insertObject:index atIndex:toIndexPath.item];
}

@end
