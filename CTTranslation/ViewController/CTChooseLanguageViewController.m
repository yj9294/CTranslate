//
//  CTChooseLanguageViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/14.
//

#import "CTChooseLanguageViewController.h"
#import "CTTranslateManager.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTPosterManager.h"

@interface CTChooseLanguageCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *langLabel;
@property (nonatomic, strong) UIImageView *downloadImageView;
@property (nonatomic, strong) CTTranslateModel *model;
@property (nonatomic, assign) BOOL langSelect;

@end

@implementation CTChooseLanguageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        
        self.langLabel = [UILabel lbText:@"" font:[UIFont fontWithSize:15] color:[UIColor whiteColor]];
        self.langLabel.numberOfLines = 3;
        self.langLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.langLabel];
        [self.langLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(35);
            make.right.mas_equalTo(-35);
            make.centerY.mas_equalTo(0);
        }];
        
        self.downloadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"change_lang_down"]];
        [self.contentView addSubview:self.downloadImageView];
        [self.downloadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.width.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setModel:(CTTranslateModel *)model {
    _model = model;
    self.langLabel.text = model.name;
    self.downloadImageView.hidden = model.isDownload;
}

- (void)setLangSelect:(BOOL)langSelect {
    if (langSelect) {
        self.contentView.backgroundColor = [UIColor hexColor:@"#D56F5E"];
        self.langLabel.font = [UIFont fontWithSize:15 weight:UIFontWeightMedium];
    } else {
        self.contentView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        self.langLabel.font = [UIFont fontWithSize:15];
    }
}

@end

@interface CTChooseLanguageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, GADFullScreenContentDelegate, GADNativeAdDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *bgAdImageView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger chooseIndex;
@property (nonatomic, assign) NSInteger oldChooseIndex;

@property (nonatomic, strong, nullable) GADNativeAdView *nativeAdView;
@property (nonatomic, strong, nullable) GADNativeAd *nativeAd;

@end

@implementation CTChooseLanguageViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] enterChooseLang];
    [[CTPosterManager sharedInstance] addReco:@"choo"];
    [self setupAdLoader];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[CTPosterManager sharedInstance] setupIsShow:NO type:CTAdvertLocationTypeSelectLangNative];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [GADUtil.shared load:GADPositionInterstital p:GADSceneSelectionInter completion:nil];
    self.chooseIndex = -1;
    self.oldChooseIndex = -1;
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    if (self.isHiddenBackButton) {
        nav.leftButton.hidden = YES;
    }
    nav.textLabel.text = @"Choose language";
    [self.view addSubview:nav];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"OK" forState:UIControlStateNormal];
    [rightButton tColor:[UIColor hexColor:@"#D56F5E"]];
    rightButton.titleLabel.font = [UIFont fontWithSize:17 weight:UIFontWeightMedium];
    [rightButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(44);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-6);
    }];
    
    [self dataSource];
    [self.view addSubview:self.collectionView];
    
    //这里判断是否能加载原生广告
    if ([[CTPosterManager sharedInstance] isCanShowAdvertWithType:CTAdvertLocationTypeSelectLangNative]) {
        self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_bg"]];
        self.bgAdImageView.userInteractionEnabled = YES;
        [self.view addSubview:self.bgAdImageView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nav.mas_bottom).offset(5);
            make.left.right.mas_equalTo(0);
        }];
        
        [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectionView.mas_bottom).offset(10);
            make.height.mas_lessThanOrEqualTo(220);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-CTBottom());
        }];
    } else {
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nav.mas_bottom).offset(5);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
}

- (void)okAction {
    if (self.chooseIndex >= 0) {
        [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"lan_i"}];
        [self displayAdvert];
    } else {
        [UIView ct_tipToast:@"no choice!"];
    }
}

- (void)displayAdvert {
    __weak typeof(self) weakSelf = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneSelectionInter from:self completion:^(GADBaseModel * _Nullable model) {
        [weakSelf jumpVCWithAnimated:YES];
    }];
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    if (self.selectModel) {
        self.selectModel(self.dataSource[self.chooseIndex]);
    }
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)setupAdLoader {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"lan_n"}];
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    CTAdvertLocationType type = CTAdvertLocationTypeSelectLangNative;
    if ([manager isCanShowAdvertWithType:type]) {
        __weak typeof(self) weakSelf = self;
        [manager syncRequestNativeAdWithType:type complete:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf == nil) return;
                if (isSuccess) {
                    GADNativeAd *nativeAd = [CTPosterManager sharedInstance].selectLangAd;
                    [CTPosterManager sharedInstance].selectLangAd = nil;
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
    GADNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil].firstObject;
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

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(5, 15, 40, 15);
        layout.itemSize = CGSizeMake((CTScreenWidth() - 40.1)/2, 90);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = self.view.backgroundColor;
        _collectionView.allowsMultipleSelection = NO;
        [_collectionView registerClass:[CTChooseLanguageCell class] forCellWithReuseIdentifier:@"CTChooseLanguageCell"];
        return _collectionView;
    }
    return _collectionView;
}

- (NSArray *)dataSource {
    if (_dataSource == nil) {
        NSUInteger count = [CTTranslateModel nameArray].count;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; i++) {
            CTTranslateModel *model = [CTTranslateModel modelWithType:i];
            model.isDownload = [CTTranslateManager hasModelWithLanguage:model.language];
            [array addObject:model];
        }
        _dataSource = [array copy];
    }
    return _dataSource;
}

//TODO: coolectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CTChooseLanguageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CTChooseLanguageCell" forIndexPath:indexPath];
    CTTranslateModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    cell.langSelect = self.chooseIndex == indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.chooseIndex == indexPath.row) return;
    CTTranslateModel *model = self.dataSource[indexPath.row];
    if (!model.isDownload) {
        //去下载
        [UIView ct_showLoading:@"Downloading..."];
        __weak typeof(self) weakSelf = self;
        [CTTranslateManager downloadWithLanguage:model.language complete:^(BOOL isSuccess) {
            if (isSuccess) {
                [UIView ct_hideLoading];
                CTTranslateModel *currentModel = self.dataSource[indexPath.row];
                currentModel.isDownload = YES;
                [weakSelf reloadCollectionViewWithIndexPath:indexPath];
                [UIView ct_tipToast:@"Download successful!"];
            } else {
                [UIView ct_hideLoading];
                [UIView ct_tipToast:@"Download failed!"];
            }
        }];
    } else {
        [self reloadCollectionViewWithIndexPath:indexPath];
    }
}

- (void)reloadCollectionViewWithIndexPath:(NSIndexPath *)indexPath {
    self.chooseIndex = indexPath.row;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    [array addObject:indexPath];
    if (self.oldChooseIndex >= 0) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.oldChooseIndex inSection:0];
        [array addObject:oldIndexPath];
        self.oldChooseIndex = self.chooseIndex;
    } else {
        self.oldChooseIndex = self.chooseIndex;
    }
    [self.collectionView reloadItemsAtIndexPaths:array];
}

#pragma mark - GADNativeAdDelegate

//1、
- (void)nativeAdDidRecordImpression:(nonnull GADNativeAd *)nativeAd {
    [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"lan_n"}];
    [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSelectLangNative];
}

//点击
- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd {
    [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSelectLangNative];
}
@end
