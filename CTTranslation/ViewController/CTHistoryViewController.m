//
//  CTHistoryViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTHistoryViewController.h"
#import "CTHistoryCell.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTHistoryPop.h"
#import "CTDbHistoryHandle.h"
#import "CTPosterManager.h"

@interface CTHistoryViewController () <UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong, nullable) GADInterstitialAd *backInterstitial;

@end

@implementation CTHistoryViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] addReco:@"hisy"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    nav.textLabel.text = @"History";
    [self.view addSubview:nav];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor hexColor:@"#12263A"];
    self.bottomView.hidden = YES;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(86);
    }];
    
    UIButton *deleteButton = [UIButton btTitle:@"Delete"];
    [deleteButton bgImage:[UIImage imageNamed:@"history_button_bg"]];
    [deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(235);
        make.height.mas_equalTo(46);
    }];
}

- (void)deleteAction {
    CTHistoryPop *pop = [[CTHistoryPop alloc] init];
    __weak typeof(self) weakSelf = self;
    [pop showWithComplete:^{
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *remainArray = [NSMutableArray arrayWithCapacity:10];
        for (CTHistoryModel *model in weakSelf.dataSource) {
            if (model.isSelect) {
                [array addObject:model];
            } else {
                model.isShowBox = NO;
                [remainArray addObject:model];
            }
        }
        
        //删除数据库里面的数据
        [CTDbHistoryHandle deleteWithModels:array];
        
        //刷新
        [weakSelf.dataSource removeAllObjects];
        [weakSelf.dataSource addObjectsFromArray:remainArray];
        [weakSelf.tableView reloadData];
        weakSelf.bottomView.hidden = YES;
    }];
}

- (void)backAction {
    [self displayAdvert];
}

- (void)displayAdvert {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"home_b"}];
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    CTAdvertLocationType type = CTAdvertLocationTypeBack;
    if ([manager isCanShowAdvertWithType:type]) {
        if ((manager.backInterstitial && [manager isCacheValidWithType:type]) || manager.substituteInterstitial) {
            if (manager.isScreenAdShow) return;
            manager.isScreenAdShow = YES;
            if (manager.backInterstitial && [manager isCacheValidWithType:type]) {
                self.backInterstitial = manager.backInterstitial;
                manager.backInterstitial = nil;
            } else {
                self.backInterstitial = manager.substituteInterstitial;
                manager.substituteInterstitial = nil;
                self.isSubstitute = YES;
            }
            
            self.backInterstitial.fullScreenContentDelegate = self;
            [UIView ct_tipForeplayWithComplete:^{
                [self.backInterstitial presentFromRootViewController:self];
            }];
        } else {
            [self jumpVCWithAnimated:YES];
        }
    } else {
        [self jumpVCWithAnimated:YES];
    }
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = self.view.backgroundColor;
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[CTHistoryCell class] forCellReuseIdentifier:@"CTHistoryCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, CTSafeAreaBottom() + 100, 0)];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSArray *array = [CTDbHistoryHandle loadAlls];
        _dataSource = [NSMutableArray arrayWithArray:array];
        //数据库里面取
    }
    return _dataSource;
}

//TODO: UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 127;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTHistoryCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CTHistoryModel *model = self.dataSource[indexPath.section];
    cell.model = model;
    __weak typeof(self) weakSelf = self;
    cell.longCell = ^{
        for (CTHistoryModel *model in weakSelf.dataSource) {
            model.isShowBox = YES;
            model.isSelect = NO;
        }
        [weakSelf.tableView reloadData];
        weakSelf.bottomView.hidden = NO;
    };
    return cell;
}

#pragma  mark - UINavigationControllerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    if ([manager isCanShowAdvertWithType:CTAdvertLocationTypeBack] && (manager.backInterstitial || manager.substituteInterstitial)) {
        [self displayAdvert];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - GADFullScreenContentDelegate
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    GADInterstitialAd *advert = (GADInterstitialAd *)ad;
    advert.paidEventHandler = ^(GADAdValue * _Nonnull value) {
        [[CTPosterManager sharedInstance] paidAdWithValue:value];
    };
}

//这里用将要消失
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    manager.isScreenAdShow = NO;
    self.backInterstitial = nil;
    if (self.isSubstitute) {
        self.isSubstitute = NO;
        [manager setupIsShow:NO type:CTAdvertLocationTypeSubstitute];
    } else {
        [manager setupIsShow:NO type:CTAdvertLocationTypeBack];
    }
    [self jumpVCWithAnimated:NO];
}

//3 点击
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
    //保存数据库点击次数
    if (self.isSubstitute) {
        [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSubstitute];
    } else {
        [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeBack];
    }
}

//1 将要展示
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    //保存数据库展示次数
    if (self.isSubstitute) {
        [CTStatisticAnalysis saveEvent:@"backup_show" params:@{@"place": @"home_b"}];
        [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSubstitute];
    } else {
        [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"home_b"}];
        [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeBack];
    }
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    manager.isScreenAdShow = NO;
    if (self.isSubstitute) {
        self.isSubstitute = NO;
        [manager advertLogFailedWithType:CTAdvertLocationTypeSubstitute error:error.localizedDescription];
    } else {
        [manager advertLogFailedWithType:CTAdvertLocationTypeBack error:error.localizedDescription];
    }
    self.backInterstitial = nil;
    [self jumpVCWithAnimated:YES];
}
@end
