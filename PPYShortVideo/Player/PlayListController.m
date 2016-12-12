//
//  PlayListController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/13.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "PlayListController.h"
#import "FlowCell.h"
#import "SVPullToRefresh.h"
#import "PlayerController.h"
#import <PPYLiveKit/PPYLiveKit.h>
#import "WebAPI.h"
#import "PlayListHelper.h"
#import "MBProgressHUD.h"

static NSString * reuseIdentifier = @"flowcell";

@interface PlayListController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PlayListHelperDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *flowView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblTip;

@property (strong, nonatomic) NSMutableArray *VODList;
@property (strong, nonatomic) PlayListHelper *helper;

@end

@implementation PlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateNavBarAndStatusBar];
    [self setupCollectionView];
    [self setupRefreshView];
    self.helper = [[PlayListHelper alloc]init];
    self.helper.delegate = self;
    self.VODList = [[NSMutableArray alloc]init];
    
    [self.flowView triggerPullToRefresh];
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.needShowUploadSuccess){
        [self notifyMessageOnUI:@"上传成功！"];
        self.needShowUploadSuccess = NO;
    }
}

-(void)notifyMessageOnUI:(NSString *)message{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:3.f];
}

-(void)doPullRefresh{
    [self.helper fetchVODList];
}
//-(void)doInfiniteScrolling{
////    [self.helper fetchLiveListWithPageNum:self.pageNum];
//}

-(void)doBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateNavBarAndStatusBar{
    self.navigationItem.title = @"短视频 DEMO";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"左上角返回.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack)];

    self.view.backgroundColor = self.navigationController.navigationBar.barTintColor;
}

-(void)setupCollectionView{
    self.flowView.backgroundColor = [UIColor whiteColor];
    
    self.flowView.delegate = self;
    self.flowView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"FlowCell" bundle:[NSBundle mainBundle]];
    [self.flowView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

-(void)setupRefreshView{
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.flowView addPullToRefreshWithActionHandler:^{
        [weakSelf doPullRefresh];
    }];
}


#pragma mark --PlayerListHelperDelegate--
-(void)didFetchVODListSuccessed:(NSArray *)list{
    if(list.count > 0){
        [self.VODList removeAllObjects];
        [self.VODList addObjectsFromArray:list];
    }else{
        
    }
    [self.flowView.pullToRefreshView stopAnimating];
    [self.flowView reloadData];
}
-(void)didFetchVODListFailured:(NetworkErrorType)type Code:(int)errorCode Info:(NSString *)errInfo{
    [self.flowView.pullToRefreshView stopAnimating];
}
#pragma mark ---UICollectionViewDelegate---
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    ShortVideoModel *model = self.VODList[indexPath.item];
    
    PlayerController *playController = [[PlayerController alloc]init];
    playController.playerURL = model.video_url;
    playController.needPlayWhenAppear = YES;
    [self.navigationController pushViewController:playController animated:YES];
}


#pragma mark ---UICollectionViewDataSource---
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.VODList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ShortVideoModel *model = self.VODList[indexPath.item];
    
    FlowCell *cell = (FlowCell *) [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.lblCreateTime.text = model.create_time_text;
    
    [self.helper downLoadWebImage:model.screen_url onQueueAsync:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(NSData *data) {
        if(data){
            cell.imgBackground.image = [UIImage imageWithData:data];
        }else{
            cell.imgBackground.image = [UIImage imageNamed:@"图层-0.png"];
        }
    }];
    return cell;
}

#pragma mark ---UICollectionViewDelegateFlowLayout---
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect rect = [UIScreen mainScreen].bounds;
    int width = rect.size.width / 2 - 10;
    
    return CGSizeMake(width, width);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
@end







