//
//  CTUserfulViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import "CTUserfulViewController.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTUserfulInfoViewController.h"
#import "CTPosterManager.h"

@interface CTUserfulCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
- (void)setContentText:(NSString *)contentText;

@end

@implementation CTUserfulCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        self.bgImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        
        self.contentLabel = [UILabel lbText:@"" font:[UIFont pFont:15] color:[UIColor whiteColor]];
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(115);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userfull_arrow"]];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-31);
            make.width.mas_equalTo(6);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)setContentText:(NSString *)contentText {
    self.contentLabel.text = contentText;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"userful_%@", contentText]];
    if (image) {
        UIEdgeInsets capInsets = UIEdgeInsetsMake(0, 88, 0, 15);
        image = [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
        self.bgImageView.image = image;
    }
}

@end

@interface CTUserfulViewController () <UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate, UIGestureRecognizerDelegate, GADNativeAdDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIImageView *bgAdImageView;

@property (nonatomic, strong, nullable) GADInterstitialAd *backInterstitial;
@property (nonatomic, strong, nullable) GADNativeAdView *nativeAdView;
@property (nonatomic, strong, nullable) GADNativeAd *nativeAd;

@property (nonatomic, strong, nullable) GADInterstitialAd *usefulInterstitial;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation CTUserfulViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] enterUseful];
    [[CTPosterManager sharedInstance] addReco:@"usef"];
    [self setupAdLoader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[CTPosterManager sharedInstance] setupIsShow:NO type:CTAdvertLocationTypeTranslateNative];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectIndex = -1;
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    nav.textLabel.text = @"Useful Expressions";
    [self.view addSubview:nav];
    BOOL isShowNativeAd = YES;
    if (isShowNativeAd) {
        self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_small_bg"]];
        self.bgAdImageView.userInteractionEnabled = YES;
        [self.view addSubview:self.bgAdImageView];
        [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-CTBottom());
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(152);
        }];
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        if (isShowNativeAd) {
            make.bottom.mas_equalTo(-CTBottom() - 162);
        } else {
            make.bottom.mas_equalTo(0);
        }
    }];
}

- (void)backAction {
    [self displayAdvert];
}

- (void)setupAdLoader {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"use_n"}];
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    CTAdvertLocationType type = CTAdvertLocationTypeTranslateNative;
    if ([manager isCanShowAdvertWithType:type]) {
        __weak typeof(self) weakSelf = self;
        [manager syncRequestNativeAdWithType:type complete:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf == nil) return;
                if (isSuccess) {
                    GADNativeAd *nativeAd = [CTPosterManager sharedInstance].translateAd;
                    [CTPosterManager sharedInstance].translateAd = nil;
                    [weakSelf addNativeViewWithNativeAd:nativeAd];
                }
            });
        }];
    } else {
        if (!self.bgAdImageView.isHidden) {
            if ([manager isShowLimt:type]) {
                self.bgAdImageView.hidden = YES;
            }
        }
    }
}

- (void)addNativeViewWithNativeAd:(GADNativeAd *)nativeAd {
    if (self.nativeAdView) {
        [self.nativeAdView removeFromSuperview];
        self.nativeAdView = nil;
    }
    
    nativeAd.delegate = self;
    self.nativeAd = nativeAd;
    self.nativeAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
        [[CTPosterManager sharedInstance] paidAdWithValue:value];
    };
    GADNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdSmallView" owner:nil options:nil].firstObject;
    self.nativeAdView = nativeAdView;
    
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
    nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    ((UILabel *)(nativeAdView.headlineView)).text = nativeAd.headline;
    
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
    
    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
    
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

//    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
//    nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
    
    nativeAdView.callToActionView.userInteractionEnabled = NO;
    nativeAdView.nativeAd = nativeAd;
    
    [self.bgAdImageView addSubview:nativeAdView];
    [nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
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
        CTUserfulInfoViewController *vc = [[CTUserfulInfoViewController alloc] init];
        vc.typeText = self.dataSource[self.selectIndex];
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
        [_tableView registerClass:[CTUserfulCell class] forCellReuseIdentifier:@"CTUserfulCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(15, 0, 45, 0)];
    }
    return _tableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"Accommodation", @"Travel", @"Diet", @"Shopping", @"Sightseeing"];
    }
    return _dataSource;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTUserfulCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTUserfulCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *text = self.dataSource[indexPath.section];
    [cell setContentText:text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"use_i"}];
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
    return 80;
}

#pragma mark - GADNativeAdDelegate

//1、
- (void)nativeAdDidRecordImpression:(nonnull GADNativeAd *)nativeAd {
    [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"use_n"}];
    [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeTranslateNative];
}

//点击
- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd {
    [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeTranslateNative];
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
            [CTStatisticAnalysis saveEvent:@"backup_show" params:@{@"place": @"use_i"}];
            [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSubstitute];
        } else {
            [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"use_i"}];
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
            [manager advertLogFailedWithType:CTAdvertLocationTypeBack error:error.localizedDescription];
        } else {
            [manager advertLogFailedWithType:CTAdvertLocationTypeSubstitute error:error.localizedDescription];
        }
        self.backInterstitial = nil;
        [self jumpVCWithAnimated:YES];
    } else if (ad == self.usefulInterstitial) {
        if (self.isSubstitute) {
            self.isSubstitute = NO;
            [manager advertLogFailedWithType:CTAdvertLocationTypeBack error:error.localizedDescription];
        } else {
            [manager advertLogFailedWithType:CTAdvertLocationTypeUseful error:error.localizedDescription];
        }
        self.usefulInterstitial = nil;
        [self jumpUserInfovcWithAnimated:YES];
    }
}
@end