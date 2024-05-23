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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [GADUtil.shared disappear:GADPositionNative];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_bg"]];
    self.bgAdImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgAdImageView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(5);
        make.left.right.mas_equalTo(0);
    }];
    
    [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(10);
        make.height.mas_lessThanOrEqualTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-CTBottom());
    }];
    
    self.nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil].firstObject;
    [self.bgAdImageView addSubview:self.nativeAdView];
    [self.nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.bgAdImageView);
    }];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nativeAdUpdate:) name:@"homeNativeUpdate" object:nil];
    [GADUtil.shared logScene:GADSceneSelectLanInter];
    [GADUtil.shared logScene:GADSceneSelectLanNative];
    [GADUtil.shared load:GADPositionInterstital p:GADSceneSelectLanInter completion:nil];
    [GADUtil.shared disappear:GADPositionNative];
    [GADUtil.shared load:GADPositionNative p:GADSceneSelectLanNative completion:nil];
    
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
    [GADUtil.shared show:GADPositionInterstital p:GADSceneSelectLanInter from:self completion:^(GADBaseModel * _Nullable model) {
        [weakSelf jumpVCWithAnimated:YES];
    }];
    [GADUtil.shared load:GADPositionInterstital p:GADSceneSelectLanInter completion:nil];
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    if (self.selectModel) {
        self.selectModel(self.dataSource[self.chooseIndex]);
    }
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)nativeAdUpdate:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    if ([model isKindOfClass:GADNativeModel.class] && model.p == GADSceneSelectLanNative) {
        GADNativeModel *nativeModel = (GADNativeModel *)model;
        if (nativeModel.nativeAd) {
            [self.bgAdImageView setHidden:false];
            [self addNativeViewWithNativeAd:nativeModel.nativeAd];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.collectionView.mas_bottom).offset(10);
                make.height.mas_lessThanOrEqualTo(220);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.bottom.mas_equalTo(self.view.mas_bottomMargin);
            }];
        } else {
            [self.bgAdImageView setHidden:true];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.collectionView.mas_bottom).offset(10);
                make.height.mas_lessThanOrEqualTo(0);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.bottom.mas_equalTo(self.view.mas_bottomMargin);
            }];
        }
    }
}

- (void)addNativeViewWithNativeAd:(GADNativeAd *)nativeAd {
    self.nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
    self.nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    ((UILabel *)(self.nativeAdView.headlineView)).text = nativeAd.headline;
    
    ((UILabel *)self.nativeAdView.bodyView).text = nativeAd.body;
    self.nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
    
    [((UIButton *)self.nativeAdView.callToActionView) setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    self.nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
    
    ((UIImageView *)self.nativeAdView.iconView).image = nativeAd.icon.image;
    self.nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;
    
    ((UILabel *)self.nativeAdView.storeView).text = nativeAd.store;
    self.nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;
    
    ((UILabel *)self.nativeAdView.priceView).text = nativeAd.price;
    self.nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;
    
    ((UILabel *)self.nativeAdView.advertiserView).text = nativeAd.advertiser;
    self.nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
    
    self.nativeAdView.callToActionView.userInteractionEnabled = NO;
    self.nativeAdView.nativeAd = nativeAd;
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
@end
