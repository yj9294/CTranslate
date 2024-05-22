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

@interface CTSettingViewController ()

@property (nonatomic, strong) UIImageView *bgAdImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong, nullable) GADNativeAdView *nativeAdView;
@property (nonatomic, strong) UIView *shareView;
@end

@implementation CTSettingViewController

- (void)didVC {
    [super didVC];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
    [self addADNotification];
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
    self.shareView = [self viewWithTitle:@"Share with friends" imageName:@"settings_share" action:@selector(shareAction)];
    
//    [self.view addSubview:languageView];
    [self.view addSubview:feedbackView];
    [self.view addSubview:policyView];
    [self.view addSubview:self.shareView];
    
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
    
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackView.mas_bottom).offset(6);
        make.left.height.width.equalTo(feedbackView);
    }];
    
    self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_bg"]];
    self.bgAdImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgAdImageView];
    [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.shareView.mas_bottom).offset(10);
        make.height.mas_lessThanOrEqualTo(220);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-CTTabHeight()-CTSafeAreaBottom()-10);
    }];
    
    self.nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdView" owner:nil options:nil].firstObject;
    [self.nativeAdView setHidden:YES];
    [self.bgAdImageView addSubview:self.nativeAdView];
    [self.nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.bgAdImageView);
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [GADUtil.shared disappear:GADPositionNative];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GADUtil.shared disappear:GADPositionNative];
    [GADUtil.shared load:GADPositionNative p:GADSceneSettingsNative completion:nil];
}

- (void)addADNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nativeAdUpdate:) name:@"homeNativeUpdate" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)nativeAdUpdate:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    if ([model isKindOfClass:GADNativeModel.class] && model.p == GADSceneSettingsNative) {
        GADNativeModel *nativeModel = (GADNativeModel *)model;
        if (nativeModel.nativeAd) {
            [self.bgAdImageView setHidden:false];
            [self.nativeAdView setHidden:false];
            [self addNativeViewWithNativeAd:nativeModel.nativeAd];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.greaterThanOrEqualTo(self.shareView.mas_bottom).offset(10);
                make.height.mas_lessThanOrEqualTo(220);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.bottom.mas_equalTo(-CTTabHeight()-CTSafeAreaBottom()-10);
            }];
        } else {
            [self.bgAdImageView setHidden:true];
            [self.nativeAdView setHidden:true];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.greaterThanOrEqualTo(self.shareView.mas_bottom).offset(10);
                make.height.mas_lessThanOrEqualTo(0);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.bottom.mas_equalTo(-CTTabHeight()-CTSafeAreaBottom()-10);
            }];
        }
    } else {
        [self.bgAdImageView setHidden:true];
        [self.nativeAdView setHidden:true];
        [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.greaterThanOrEqualTo(self.shareView.mas_bottom).offset(10);
            make.height.mas_lessThanOrEqualTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-CTTabHeight()-CTSafeAreaBottom()-10);
        }];
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

@end
