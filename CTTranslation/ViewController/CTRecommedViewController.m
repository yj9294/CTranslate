//
//  CTRecommedViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTRecommedViewController.h"
#import "CTNavigationView.h"
#import "CTHomeTableViewCell.h"
#import "UIView+CT.h"
#import "CTRecommandInfoViewController.h"
#import "CTFbHandle.h"
#import "CTPosterManager.h"

@interface CTRecommedViewController () <UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong, nullable) GADInterstitialAd *backInterstitial;
@property (nonatomic, strong, nullable) GADInterstitialAd *usefulInterstitial;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation CTRecommedViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] addReco:@"reco"];
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
    self.selectIndex = -1;
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    nav.textLabel.text = @"Recommend";
    [self.view addSubview:nav];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)backAction {
    [self displayAdvert];
}

- (void)displayUsefulAdvert {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    CTAdvertLocationType type = CTAdvertLocationTypeUseful;
    if ([manager isCanShowAdvertWithType:type]) {
        if ((manager.usefulInterstitial && [manager isCacheValidWithType:type]) || manager.substituteInterstitial) {
            if (manager.isScreenAdShow) return;
            manager.isScreenAdShow = YES;
            if (manager.usefulInterstitial && [manager isCacheValidWithType:type]) {
                self.usefulInterstitial = manager.usefulInterstitial;
                manager.usefulInterstitial = nil;
            } else {
                self.usefulInterstitial = manager.substituteInterstitial;
                manager.substituteInterstitial = nil;
                self.isSubstitute = YES;
            }
            
            self.usefulInterstitial.fullScreenContentDelegate = self;
            [UIView ct_tipForeplayWithComplete:^{
                [self.usefulInterstitial presentFromRootViewController:self];
            }];
        } else {
            [self jumpUserInfovcWithAnimated:YES];
        }
    } else {
        [self jumpUserInfovcWithAnimated:YES];
    }
}

- (void)jumpUserInfovcWithAnimated:(BOOL)animated {
    if (self.selectIndex >= 0) {
        CTRecommandInfoViewController *vc = [[CTRecommandInfoViewController alloc] init];
        vc.translateText = self.dataSource[self.selectIndex];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
        [_tableView registerClass:[CTHomeTableViewCell class] forCellReuseIdentifier:@"CTHomeTableViewCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, 45, 0)];
    }
    return _tableView;
}
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSArray *array = [[CTFbHandle shared] getRecommendList];
        _dataSource = [NSMutableArray arrayWithArray:array];
    }
    return _dataSource;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTHomeTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *text = self.dataSource[indexPath.section];
    cell.contentLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"reco_i"}];
    self.selectIndex = indexPath.section;
    [self displayUsefulAdvert];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
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
    if (ad == self.backInterstitial) {
        self.backInterstitial = nil;
        if (self.isSubstitute) {
            self.isSubstitute = NO;
            [manager setupIsShow:NO type:CTAdvertLocationTypeSubstitute];
        } else {
            [manager setupIsShow:NO type:CTAdvertLocationTypeBack];
        }
        [self jumpVCWithAnimated:NO];
    } else if (ad == self.usefulInterstitial) {
        self.usefulInterstitial = nil;
        if (self.isSubstitute) {
            self.isSubstitute = NO;
            [manager setupIsShow:NO type:CTAdvertLocationTypeSubstitute];
        } else {
            [manager setupIsShow:NO type:CTAdvertLocationTypeUseful];
        }
        [self jumpUserInfovcWithAnimated:NO];
    }
}

//3 点击
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
    //保存数据库点击次数
    if (ad == self.backInterstitial) {
        if (self.isSubstitute) {
            [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSubstitute];
        } else {
            [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeBack];
        }
    } else if (ad == self.usefulInterstitial) {
        if (self.isSubstitute) {
            [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSubstitute];
        } else {
            [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeUseful];
        }
    }
}

//1 将要展示
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    //保存数据库展示次数
    if (ad == self.backInterstitial) {
        if (self.isSubstitute) {
            [CTStatisticAnalysis saveEvent:@"backup_show" params:@{@"place": @"home_b"}];
            [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSubstitute];
        } else {
            [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"home_b"}];
            [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeBack];
        }
    } else if (ad == self.usefulInterstitial) {
        if (self.isSubstitute) {
            [CTStatisticAnalysis saveEvent:@"backup_show" params:@{@"place": @"reco_i"}];
            [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSubstitute];
        } else {
            [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"reco_i"}];
            [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeUseful];
        }
    }
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    manager.isScreenAdShow = NO;
    if (ad == self.backInterstitial) {
        if (self.isSubstitute) {
            self.isSubstitute = NO;
            [manager advertLogFailedWithType:CTAdvertLocationTypeSubstitute error:error.localizedDescription];
        } else {
            [manager advertLogFailedWithType:CTAdvertLocationTypeBack error:error.localizedDescription];
        }
        self.backInterstitial = nil;
        [self jumpVCWithAnimated:YES];
    } else if (ad == self.usefulInterstitial) {
        if (self.isSubstitute) {
            self.isSubstitute = NO;
            [manager advertLogFailedWithType:CTAdvertLocationTypeSubstitute error:error.localizedDescription];
        } else {
            [manager advertLogFailedWithType:CTAdvertLocationTypeUseful error:error.localizedDescription];
        }
        self.usefulInterstitial = nil;
        [self jumpUserInfovcWithAnimated:YES];
    }
}

@end
