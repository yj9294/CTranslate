//
//  CTHomeViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTHomeViewController.h"
#import "CTRecommedViewController.h"
#import "CTRecommandInfoViewController.h"
#import "CTHistoryViewController.h"
#import "CTTranslateViewController.h"
#import "CTDialogueViewController.h"
#import "CTUserfulViewController.h"
#import "CTHomeHeaderView.h"
#import "CTHomeTableViewCell.h"
#import "UIView+CT.h"
#import "CTFbHandle.h"
#import "CTPosterManager.h"
#import "CTFbHandle.h"

@interface CTHomeViewController () <UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate>

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CTHomeHeaderView *headerView;
@property (nonatomic, assign) CTHomeSelectType type;
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong, nullable) GADInterstitialAd *clickInterstitial;

@end

@implementation CTHomeViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] enterHome];
    [[CTPosterManager sharedInstance] addReco:@"home"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ((CTStatusHeight() != 0) && self.titleImageView.frame.origin.y == 20) {
        [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(CTStatusHeight() + 20);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *model = [CTFirebase getAppMode];
    [CTStatisticAnalysis saveEvent:@"home_mode" params:@{@"mode": model}];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_title"]];
    self.titleImageView = titleImageView;
    [self.view addSubview:titleImageView];
    [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(CTStatusHeight() + 20);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(185);
        make.height.mas_equalTo(65);
    }];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleImageView.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-CTTabHeight() - CTSafeAreaBottom());
    }];
    
    __weak typeof(self) weakSelf = self;
    self.headerView.selectItem = ^(CTHomeSelectType type) {
        weakSelf.type = type;
        [weakSelf displayAdvert];
    };
    
    UIButton *historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [historyButton bgImage:[UIImage imageNamed:@"home_history"]];
    [historyButton addTarget:self action:@selector(historyActoin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:historyButton];
    [historyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(CTStatusHeight() + 480);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(64);
    }];
}

- (void)historyActoin {
    self.type = CTHomeSelectTypeHistory;
    [self displayAdvert];
}

- (void)displayAdvert {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"home_c"}];
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    CTAdvertLocationType type = CTAdvertLocationTypeClick;
    if ([manager isCanShowAdvertWithType:type]) {
        if ((manager.clickInterstitial && [manager isCacheValidWithType:type]) || manager.substituteInterstitial) {
            if (manager.isScreenAdShow) return;
            manager.isScreenAdShow = YES;
            if (manager.clickInterstitial && [manager isCacheValidWithType:type]) {
                self.clickInterstitial = manager.clickInterstitial;
                manager.clickInterstitial = nil;
            } else {
                self.clickInterstitial = manager.substituteInterstitial;
                manager.substituteInterstitial = nil;
                self.isSubstitute = YES;
            }
            
            self.clickInterstitial.fullScreenContentDelegate = self;
            [UIView ct_tipForeplayWithComplete:^{
                [self.clickInterstitial presentFromRootViewController:self];
            }];
        } else {
            [self jumpVCWithAnimated:YES];
        }
    } else {
        [self jumpVCWithAnimated:YES];
    }
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    [[CTPosterManager sharedInstance] jumpHome];
    CTBaseViewController *vc;
    switch (self.type) {
        case CTHomeSelectTypeDia:
            vc = [[CTDialogueViewController alloc] init];
            break;
        case CTHomeSelectTypeText:
            vc = [[CTTranslateViewController alloc] initWithType:CTTranslateTypeText];
            break;
        case CTHomeSelectTypeVoice:
            vc = [[CTTranslateViewController alloc] initWithType:CTTranslateTypeVoice];
            break;
        case CTHomeSelectTypeCamera:
            vc = [[CTTranslateViewController alloc] initWithType:CTTranslateTypeCamera];
            break;
        case CTHomeSelectTypeUseful:
            vc = [[CTUserfulViewController alloc] init];
            break;
        case CTHomeSelectTypeMore:
            vc = [[CTRecommedViewController alloc] init];
            break;
        case CTHomeSelectTypeHistory:
            vc = [[CTHistoryViewController alloc] init];
            break;
        case CTHomeSelectTypeRecommandInfo: {
            CTRecommandInfoViewController *infoVc = [[CTRecommandInfoViewController alloc] init];
            infoVc.isHomeEnter = YES;
            if (self.selectIndex >= 0) {
                infoVc.translateText = self.dataSource[self.selectIndex];
            }
            vc = infoVc;
            break;
        }
        default:
            break;
    }
    if (vc) {
        [self.navigationController pushViewController:vc animated:animated];
    }
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
    self.type = CTHomeSelectTypeRecommandInfo;
    self.selectIndex = indexPath.section;
    [self displayAdvert];
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = self.view.backgroundColor;
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[CTHomeTableViewCell class] forCellReuseIdentifier:@"CTHomeTableViewCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, 15, 0)];
    }
    return _tableView;
}

- (CTHomeHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[CTHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, CTScreenWidth(), 341)];
    }
    return _headerView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSArray *array = [[CTFbHandle shared] getRecommendList];
        _dataSource = [NSMutableArray arrayWithArray:array];
    }
    return _dataSource;
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
    self.clickInterstitial = nil;
    if (self.isSubstitute) {
        self.isSubstitute = NO;
        [manager setupIsShow:NO type:CTAdvertLocationTypeSubstitute];
    } else {
        [manager setupIsShow:NO type:CTAdvertLocationTypeClick];
    }
    [self jumpVCWithAnimated:NO];
}

//3 点击
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
    //保存数据库点击次数
    if (self.isSubstitute) {
        [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSubstitute];
    } else {
        [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeClick];
    }
}

//1 将要展示
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    //保存数据库展示次数
    if (self.isSubstitute) {
        [CTStatisticAnalysis saveEvent:@"backup_show" params:@{@"place": @"home_c"}];
        [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSubstitute];
    } else {
        [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"home_c"}];
        [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeClick];
    }
    
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    manager.isScreenAdShow = NO;
    if (self.isSubstitute) {
        self.isSubstitute = NO;
        [manager advertLogFailedWithType:CTAdvertLocationTypeSubstitute error:error.localizedDescription];
    } else {
        [manager advertLogFailedWithType:CTAdvertLocationTypeClick error:error.localizedDescription];
    }
    self.clickInterstitial = nil;
    [self jumpVCWithAnimated:YES];
}


@end
