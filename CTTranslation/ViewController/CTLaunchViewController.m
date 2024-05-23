//
//  CTLaunchViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2023/12/28.
//

#import "CTLaunchViewController.h"
#import "Masonry/Masonry.h"
#import "UIView+CT.h"
#import "AFNetworking/AFNetworking.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "CTMainViewController.h"
#import "UIView+CT.h"
#import "CTLaunchViewController.h"
#import "CTDbAdvertHandle.h"
#import "NSObject+CT.h"
#import "CTTanslatePrivacyPop.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CTTranslateManager.h"
#import "CTChooseLanguageViewController.h"
#import "CTStatisticAnalysis.h"
#import "CTChangeLangugeView.h"

@implementation CTLaunchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_logo"]];
        [self addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(110);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(117);
            make.height.mas_equalTo(87);
        }];
        
        UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_title"]];
        [self addSubview:titleImageView];
        [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(217);
            make.width.mas_equalTo(170);
            make.height.mas_equalTo(18);
            make.centerX.mas_equalTo(0);
        }];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_bg"]];
        bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(387);
            make.height.mas_equalTo(295);
            make.centerX.mas_equalTo(0);
        }];
        
        [self addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-30);
            make.width.mas_equalTo(235);
            make.height.mas_equalTo(8);
            make.centerX.mas_equalTo(0);
        }];
        
    }
    return self;
}

- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.tintColor = [UIColor hexColor:@"#D9D9D9"];
        _progressView.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _progressView.layer.cornerRadius = 4;
        _progressView.layer.masksToBounds = YES;
    }
    return _progressView;
}

@end

@interface CTLaunchViewController ()
@property (nonatomic, strong) CTMainViewController *home;
@property (nonatomic, strong) CTLaunchView *launchView;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CTLaunchViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    self.launchView = [[CTLaunchView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.launchView];
}

- (void)launch {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self progressManager];
    [self showLaunch];
}

- (void)showLaunch {
    AppManager.shared.window.rootViewController = self;
}

- (void)showHome {
    if ([AppManager.shared getNeedChooseVC]) {
        CTChooseLanguageViewController *vc = [[CTChooseLanguageViewController alloc] init];
        vc.isHiddenBackButton = YES;
        vc.selectModel = ^(CTTranslateModel * _Nonnull model) {
            [AppManager.shared updateNeedChooseVC];
            AppManager.shared.window.rootViewController = [[CTMainViewController alloc] init];
        };
        AppManager.shared.window.rootViewController = vc;
    } else {
        AppManager.shared.window.rootViewController = [[CTMainViewController alloc] init];
    }
}

- (void)progressManager {
    __weak typeof(self) weakSelf = self;
    __block int duration = 15.0;
    self.launchView.progressView.progress = 0.0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.launchView.progressView.progress >= 1.0) {
            [timer invalidate];
            [GADUtil.shared show:GADPositionOpen p:GADSceneLaunOpen from:weakSelf completion:^(GADBaseModel * _Nullable ret) {
                if (weakSelf.launchView.progressView.progress >= 1.0) {
                    [weakSelf showHome];
                }
            }];
        } else {
            weakSelf.launchView.progressView.progress += (0.01 / duration);
        }
        
        if (weakSelf.launchView.progressView.progress > 0.14 && [GADUtil.shared isDidLoaded:GADPositionOpen]) {
            duration = 0.01;
        }
        
    }];
    [GADUtil.shared load:GADPositionOpen p:GADSceneLaunOpen completion:nil];
    [GADUtil.shared logScene:GADSceneLaunOpen];
}
@end
