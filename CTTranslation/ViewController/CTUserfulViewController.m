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

@interface CTUserfulViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIImageView *bgAdImageView;
@property (nonatomic, strong, nullable) GADNativeAdView *nativeAdView;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation CTUserfulViewController

- (void)didVC {
    [super didVC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [GADUtil.shared disappear:GADPositionNative];
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
    self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_small_bg"]];
    self.bgAdImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgAdImageView];
    [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-CTBottom());
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(152);
    }];
    
    self.nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdSmallView" owner:nil options:nil].firstObject;
    [self.bgAdImageView addSubview:self.nativeAdView];
    [self.nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.bgAdImageView);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-CTBottom() - 162);
    }];
    
    [self addADNotification];

    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    [GADUtil.shared load:GADPositionInterstital p:GADSceneUserfulInter completion:nil];
    [GADUtil.shared disappear:GADPositionNative];
    [GADUtil.shared load:GADPositionNative p:GADSceneUsefulNative completion:nil];
    
    [GADUtil.shared logScene:GADSceneUsefulNative];
}


- (void)addADNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nativeAdUpdate:) name:@"homeNativeUpdate" object:nil];
}

- (void)nativeAdUpdate:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    if ([model isKindOfClass:GADNativeModel.class] && model.p == GADSceneSettingsNative) {
        GADNativeModel *nativeModel = (GADNativeModel *)model;
        if (nativeModel.nativeAd) {
            [self.bgAdImageView setHidden:false];
            [self.nativeAdView setHidden:false];
            [self addNativeViewWithNativeAd:nativeModel.nativeAd];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-CTBottom());
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(152);
            }];
        } else {
            [self.bgAdImageView setHidden:true];
            [self.nativeAdView setHidden:true];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-CTBottom());
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(9);
            }];
        }
    } else {
        [self.bgAdImageView setHidden:true];
        [self.nativeAdView setHidden:true];
        [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-CTBottom());
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(0);
        }];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backAction {
    [self displayBackAdvert];
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

//    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
//    nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

    ((UILabel *)self.nativeAdView.storeView).text = nativeAd.store;
    self.nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)self.nativeAdView.priceView).text = nativeAd.price;
    self.nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

    ((UILabel *)self.nativeAdView.advertiserView).text = nativeAd.advertiser;
    self.nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
    
    self.nativeAdView.callToActionView.userInteractionEnabled = NO;
    self.nativeAdView.nativeAd = nativeAd;
    
    [self.bgAdImageView addSubview:self.nativeAdView];
    [self.nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
}

- (void)displayUsefulAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneUserfulInter completion:nil];
    __weak typeof(self) __self = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneUserfulInter from:self completion:^(GADBaseModel * _Nullable mode) {
        [__self jumpUserInfovcWithAnimated:YES];
    }];
    [GADUtil.shared logScene:GADSceneUserfulInter];
}

- (void)jumpUserInfovcWithAnimated:(BOOL)animated {
    if (self.selectIndex >= 0) {
        CTUserfulInfoViewController *vc = [[CTUserfulInfoViewController alloc] init];
        vc.typeText = self.dataSource[self.selectIndex];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)displayBackAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    __weak typeof(self) __self = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneBackHomeInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__self jumpVCWithAnimated:YES];
    }];
    [GADUtil.shared logScene:GADSceneBackHomeInter];
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:animated];
    });
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

#pragma  mark - UINavigationControllerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self displayBackAdvert];
    return  false;
}
@end
