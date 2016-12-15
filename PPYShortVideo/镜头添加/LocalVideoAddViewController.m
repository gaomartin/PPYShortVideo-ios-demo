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

#define kItemCountInVideoListCell 4

@interface LocalVideoAddViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *albumVideoInfos;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation LocalVideoAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _albumVideoInfos = [NSMutableArray array];
    [self loadLocalVideo];
    
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


@end
