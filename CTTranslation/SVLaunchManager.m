//
//  SVLaunchManager.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/8.
//

#import "SVLaunchManager.h"
#import "AFNetworking/AFNetworking.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "CTMainViewController.h"
#import "UIView+CT.h"
#import "CTLaunchViewController.h"
#import "CTDbAdvertHandle.h"
#import "CTFbHandle.h"
#import "NSObject+CT.h"
#import "CTTanslatePrivacyPop.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CTPosterManager.h"
#import "CTTranslateManager.h"
#import "CTChooseLanguageViewController.h"
#import "CTStatisticAnalysis.h"
#import "CTChangeLangugeView.h"

@interface SVLaunchManager () <GADFullScreenContentDelegate>


@property (nonatomic, assign) BOOL isShowLaunch;
@property (nonatomic, assign) BOOL isTimeout;
@property (nonatomic, assign) BOOL isSubstitute;
@property (nonatomic, strong) CTMainViewController *home;

@property (nonatomic, strong) id launchAd;

@end

@implementation SVLaunchManager

+ (SVLaunchManager *)shared {
    static SVLaunchManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SVLaunchManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isInit = NO;
        self.isTimeout = YES;
    }
    return self;
}

- (void)launch {
    [self displayLaunch];
    [self networkManager];
    [self keyboardManager];
    [self uiConfigure];
}

- (void)keyboardManager {
    [[IQKeyboardManager sharedManager] setShouldShowToolbarPlaceholder:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}

- (void)uiConfigure {
    [[UITableView appearance] setEstimatedRowHeight:0];
    [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    [[UITableView appearance] setEstimatedSectionFooterHeight:0];
    [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
}

- (void)networkManager {
    __weak typeof(self) weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status > 0) {
            weakSelf.isInit = YES;
            if (weakSelf.isTimeout) {
                weakSelf.isTimeout = NO;
                ctdispatch_async_main_safe(^ {
                    [weakSelf idfaCheckWithComplete:^{
                        [CTFirebase configureAdvert];
                        [weakSelf configureData];
                    }];
                });
            }
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.isTimeout) {
            weakSelf.isTimeout = NO;
            [CTFirebase configureAdvert];
            [[CTPosterManager sharedInstance] setupWithComplete:nil];
            [[CTPosterManager sharedInstance] enterLaunch];
            [weakSelf privacyCheckWithComplete:^{
                [weakSelf idfaCheckWithComplete:^{
                    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus > 0) {
                        [weakSelf configureData];
                    } else {
                        [weakSelf showHome];
                    }
                }];
            }];
        }
    });
}

- (void)idfaCheckWithComplete:(void(^)(void))complete {
    if (@available(iOS 14, *)) {
        if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    } else {
                    }
                    if (complete) complete();
                }];
            });
        } else {
            if (complete) complete();
        }
    } else {
        if (complete) complete();
    }
}

- (void)privacyCheckWithComplete:(void(^)(void))complete {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *flag = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAgreePrivacy"];
        if (flag.length > 0) {
            if (complete) complete();
        } else {
            CTTanslatePrivacyPop *pop = [[CTTanslatePrivacyPop alloc] init];
            [pop showWithComplete:^{
                [[NSUserDefaults standardUserDefaults] setObject:@"Agree" forKey:@"isAgreePrivacy"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (complete) complete();
            }];
        }
    });
}

- (void)languageConfigure {
    MLKTranslateLanguage language = MLKTranslateLanguageChinese;
    if (![CTTranslateManager hasModelWithLanguage:language]) {
        [CTTranslateManager downloadWithLanguage:language complete:^(BOOL isSuccess) {
            
        }];
    }
}

- (void)displayLaunch {
    UIWindow *window = [self getHomeWindow];
    if ([window.rootViewController isKindOfClass:[CTLaunchViewController class]]) return;
    self.isShowLaunch = YES;
    CTLaunchViewController *launch = [[CTLaunchViewController alloc] init];
    [window setRootViewController:launch];
    [window makeKeyAndVisible];
}

- (UIWindow *)getHomeWindow {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    return window;
}

- (void)displayLaunchView {
    if (self.isShowLaunch) return;
    self.isShowLaunch = YES;
    //展示启动页的时候去获取一次
    [CTFirebase appInfoWithComplete:^(BOOL isSuccess, id  _Nonnull config) {
        if (isSuccess) {
            [[CTPosterManager sharedInstance] setupWithComplete:nil];
        }
    }];
    
    UIWindow *window = [self getHomeWindow];
    CTLaunchView *launchView = [[CTLaunchView alloc] initWithFrame:window.bounds];
    launchView.tag = 200;
    [window addSubview:launchView];
    [[CTPosterManager sharedInstance] enterLaunch];
    __weak typeof(self) weakSelf = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showAdvert];
    });
}

- (void)hiddenLaunchView {
    UIWindow *window = [self getHomeWindow];
    UIView *view = [window viewWithTag:200];
    [view removeFromSuperview];
    if (view) {
        view = nil;
        [[CTPosterManager sharedInstance] enterForeground];
    }
}

- (void)showHome {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf privacyCheckWithComplete:^{
            UIWindow *window = [weakSelf getHomeWindow];
            if (!weakSelf.home) {
                weakSelf.home = [[CTMainViewController alloc] init];
            }
            if ([window.rootViewController isKindOfClass:[CTMainViewController class]]) {
                [weakSelf hiddenLaunchView];
            } else {
                [window setRootViewController:weakSelf.home];
                [window makeKeyAndVisible];
            }
            weakSelf.isShowLaunch = NO;
//            NSString *text = [[NSUserDefaults standardUserDefaults] stringForKey:@"showChoosevc"];
//            if (text.length > 0) {
//                UIWindow *window = [weakSelf getHomeWindow];
//                if (!weakSelf.home) {
//                    weakSelf.home = [[CTMainViewController alloc] init];
//                }
//                if ([window.rootViewController isKindOfClass:[CTMainViewController class]]) {
//                    [weakSelf hiddenLaunchView];
//                } else {
//                    [window setRootViewController:weakSelf.home];
//                    [window makeKeyAndVisible];
//                }
//                weakSelf.isShowLaunch = NO;
//            } else {
//                UIWindow *window = [weakSelf getHomeWindow];
//                if ([window.rootViewController isKindOfClass:[CTChooseLanguageViewController class]]) {
//                    [weakSelf hiddenLaunchView];
//                    weakSelf.isShowLaunch = NO;
//                    return;
//                }
//                CTChooseLanguageViewController *vc = [[CTChooseLanguageViewController alloc] init];
//                vc.isHiddenBackButton = YES;
//                vc.selectModel = ^(CTTranslateModel * _Nonnull model) {
//                    [[NSUserDefaults standardUserDefaults] setObject:@(model.type) forKey:SOURCE_LANGUGE];
//                    weakSelf.home = [[CTMainViewController alloc] init];
//                    window.rootViewController = weakSelf.home;
//                    [window makeKeyAndVisible];
//                    [[NSUserDefaults standardUserDefaults] setObject:@"showChoosevc" forKey:@"showChoosevc"];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                };
//                window.rootViewController = vc;
//                [window makeKeyAndVisible];
//                weakSelf.isShowLaunch = NO;
//            }
        }];
    });
}

- (void)configureData {
    [self languageConfigure];
    [CTFirebase configureAdvert];
    __weak typeof(self) weakSelf = self;
    [[CTPosterManager sharedInstance] setupWithComplete:^(BOOL isSuccess) {
        [[CTPosterManager sharedInstance] enterLaunch];
        if (isSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showAdvert];
            });
        } else {
            [weakSelf showHome];
        }
    }];
    [CTFirebase appInfoWithComplete:^(BOOL isSuccess, id  _Nonnull config) {
        if (isSuccess) {
            [[CTPosterManager sharedInstance] setupWithComplete:nil];
        }
    }];
}

- (void)showAdvert {
    if (!self.isInit) return;
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    if (manager.launchModel.isw) return;
    [CTStatisticAnalysis saveEvent:@"gag_chungjung" params:@{@"place": @"load"}];
    if ([manager isCanShowAdvertWithType:CTAdvertLocationTypeLaunch]) {
        if ((manager.launchAd && [manager isCacheValidWithType:CTAdvertLocationTypeLaunch]) || manager.substituteInterstitial) {
            if (manager.launchAd && [manager isCacheValidWithType:CTAdvertLocationTypeLaunch]) {
                self.launchAd = manager.launchAd;
                manager.launchAd = nil;
            } else {
                self.launchAd = manager.substituteInterstitial;
                manager.substituteInterstitial = nil;
                self.isSubstitute = YES;
            }
            [self configureAndShowLaunchAd];
        } else {
            [manager syncRequestScreenAdWithType:CTAdvertLocationTypeLaunch timeout:15 complete:^(BOOL isSuccess) {
                if (isSuccess && manager.launchAd) {
                    self.launchAd = manager.launchAd;
                    manager.launchAd = nil;
                    [self configureAndShowLaunchAd];
                } else {
                    if (manager.substituteInterstitial) {
                        self.launchAd = manager.substituteInterstitial;
                        manager.substituteInterstitial = nil;
                        self.isSubstitute = YES;
                        [self configureAndShowLaunchAd];
                    } else {
                        [self showHome];
                    }
                }
            }];
        }
    } else {
        [self showHome];
    }
}

- (void)configureAndShowLaunchAd {
    ctdispatch_async_main_safe(^{
        UIWindow *window = [self getHomeWindow];
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            UIView *view = [window viewWithTag:200];
            [view removeFromSuperview];
            if (view) {
                self.isShowLaunch = NO;
            }
            return;
        }
        
        if ([CTPosterManager sharedInstance].isScreenAdShow) return;
        [CTPosterManager sharedInstance].isScreenAdShow = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [CTStatisticAnalysis saveEvent:@"scene_load" params:nil];
            UIViewController *vc = window.rootViewController;
            if ([self.launchAd isKindOfClass:[GADAppOpenAd class]]) {
                ((GADAppOpenAd *)self.launchAd).fullScreenContentDelegate = self;
                [((GADAppOpenAd *)self.launchAd) presentFromRootViewController:vc];
            } else if ([self.launchAd isKindOfClass:[GADInterstitialAd class]]) {
                ((GADInterstitialAd *)self.launchAd).fullScreenContentDelegate = self;
                [((GADInterstitialAd *)self.launchAd) presentFromRootViewController:vc];
            } else {
                [CTPosterManager sharedInstance].isScreenAdShow = NO;
            }
        });
    });
}

- (void)gotoUpstage {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    [manager resetAdLoad];
    [manager requestLaunchAd];
}

#pragma mark - GADFullScreenContentDelegate
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    if ([ad isKindOfClass:[GADAppOpenAd class]]) {
        GADAppOpenAd *advert = (GADAppOpenAd *)ad;
        advert.paidEventHandler = ^(GADAdValue * _Nonnull value) {
            [[CTPosterManager sharedInstance] paidAdWithValue:value];
        };
    } else{
        GADInterstitialAd *advert = (GADInterstitialAd *)ad;
        advert.paidEventHandler = ^(GADAdValue * _Nonnull value) {
            [[CTPosterManager sharedInstance] paidAdWithValue:value];
        };
    }
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    manager.isScreenAdShow = NO;
    if (self.isSubstitute) {
        self.isSubstitute = NO;
        [manager setupIsShow:NO type:CTAdvertLocationTypeSubstitute];
    } else {
        [manager setupIsShow:NO type:CTAdvertLocationTypeLaunch];
    }
    self.launchAd = nil;
    [self showHome];
    [manager requestLaunchAd];
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    if (self.isSubstitute) {
        [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeSubstitute];
        [CTStatisticAnalysis saveEvent:@"backup_show" params:@{@"place": @"load"}];
    } else {
        [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeLaunch];
        [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"load"}];
    }
}

- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
    if (self.isSubstitute) {
        [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeSubstitute];
    } else {
        [[CTPosterManager sharedInstance] setupCckWithType:CTAdvertLocationTypeLaunch];
    }
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    CTPosterManager *manager = [CTPosterManager sharedInstance];
    manager.isScreenAdShow = NO;
    if (self.isSubstitute) {
        self.isSubstitute = NO;
        [manager advertLogFailedWithType:CTAdvertLocationTypeSubstitute error:error.localizedDescription];
    } else {
        [manager advertLogFailedWithType:CTAdvertLocationTypeLaunch error:error.localizedDescription];
    }
    self.launchAd = nil;
    [self showHome];
}

@end
