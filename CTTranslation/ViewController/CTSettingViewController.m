//
//  CTSettingViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTSettingViewController.h"
#import "CTChooseLanguageViewController.h"
#import "CTWebVC.h"
#import "CTFeedbacksViewController.h"
#import "CTChangeLangugeView.h"
#import "UIView+CT.h"
#import "CTTools.h"
#import "CTPosterManager.h"

@interface CTSettingViewController () <GADNativeAdDelegate>

@property (nonatomic, strong) UIImageView *bgAdImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong, nullable) GADNativeAdView *nativeAdView;
@property (nonatomic, strong, nullable) GADNativeAd *nativeAd;

@end

@implementation CTSettingViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] addReco:@"set"];
    [self setupAdLoader];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[CTPosterManager sharedInstance] setupIsShow:NO type:CTAdvertLocationTypeSetNative];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ((CTStatusHeight() != 0) && self.titleLabel.frame.origin.y == 15) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(CTStatusHeight() + 15);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    
    UILabel *titleLabel = [UILabel lbText:@"Settings" font:[UIFont fontWithSize:17 weight:UIFontWeightMedium] color:[UIColor whiteColor]];
    self.titleLabel = titleLabel;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(CTStatusHeight() + 15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(24);
    }];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_logo"]];
    [self.view addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(30);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(67);
    }];
    
    UIImageView *nameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_title"]];
    [self.view addSubview:nameImageView];
    [nameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(128);
        make.height.mas_equalTo(13);
    }];
    
    UILabel *versionLabel = [UILabel lbText:[NSString stringWithFormat:@"Version %@", [CTTools ct_getAppVersion]] font:[UIFont fontWithSize:14] color:[UIColor colorWithWhite:1 alpha:0.6]];
    [self.view addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameImageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(0);
    }];
    
//    UIView *languageView = [self viewWithTitle:@"Choose language" imageName:@"settings_choose" action:@selector(languageAction)];
    UIView *feedbackView = [self viewWithTitle:@"Feedbacks" imageName:@"settings_feed" action:@selector(feedbackAction)];
    UIView *policyView = [self viewWithTitle:@"Privacy policy" imageName:@"settings_policy" action:@selector(policyAction)];
    UIView *shareView = [self viewWithTitle:@"Share with friends" imageName:@"settings_share" action:@selector(shareAction)];
    
//    [self.view addSubview:languageView];
    [self.view addSubview:feedbackView];
    [self.view addSubview:policyView];
    [self.view addSubview:shareView];
    
//    [languageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(versionLabel.mas_bottom).offset(20);
//        make.left.mas_equalTo(15);
//        make.height.mas_equalTo(88);
//    }];
    
    [feedbackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(versionLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(88);
    }];
    
    [policyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackView);
        make.right.mas_equalTo(-15);
        make.left.equalTo(feedbackView.mas_right).offset(10);
        make.width.height.equalTo(feedbackView);
    }];
    
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackView.mas_bottom).offset(6);
        make.left.height.width.equalTo(feedbackView);
    }];
    
    self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_bg"]];
    self.bgAdImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgAdImageView];
    [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(shareView.mas_bottom).offset(10);
        make.height.mas_lessThanOrEqualTo(220);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-CTTabHeight()-CTSafeAreaBottom()-10);
    }];
}

- (UIView *)viewWithTitle:(NSString *)title imageName:(NSString *)imageName action:(SEL)action {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor hexColor:@"#5D6B83"];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:tap];
    
    UILabel *label = [UILabel lbText:title font:[UIFont pFont:16] color:[UIColor whiteColor]];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(0);
    }];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [view addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
        make.width.height.mas_equalTo(30);
    }];
    return view;
}

- (void)languageAction {
    CTChooseLanguageViewController *vc = [[CTChooseLanguageViewController alloc] init];
    vc.selectModel = ^(CTTranslateModel * _Nonnull model) {
      //保存到左边
        [[NSUserDefaults standardUserDefaults] setObject:@(model.type) forKey:SOURCE_LANGUGE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)feedbackAction {
    CTFeedbacksViewController *vc = [[CTFeedbacksViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)policyAction {
    CTWebVC *vc = [[CTWebVC alloc] initWithUrl:@"https://sites.google.com/view/co-translation"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)shareAction {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[@"https://itunes.apple.com/app/id"] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setupAdLoader {
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"set_n"}];
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    CTAdvertLocationType type = CTAdvertLocationTypeSetNative;
    if ([manager isCanShowAdvertWithType:type]) {
        __weak typeof(self) weakSelf = self;
        [manager syncRequestNativeAdWithType:type complete:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf == nil) return;
                if (isSuccess) {
                    GADNativeAd *nativeAd = [CTPosterManager sharedInstance].setAd;
                    [CTPosterManager sharedInstance].setAd = nil;
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

#pragma mark - GADNativeAdDelegate

//1、
- (void)nativeAdDidRecordImpression:(nonnull GADNativeAd *)nativeAd {
    [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"set_n"}];
    [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSetNative];
}

//点击
- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd {
    [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSetNative];
}

@end
