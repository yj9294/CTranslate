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
#import "CTTranslateManager.h"
#import "CTChooseLanguageViewController.h"
#import "CTStatisticAnalysis.h"
#import "CTChangeLangugeView.h"

@interface SVLaunchManager ()


@property (nonatomic, assign) BOOL isShowLaunch;
@property (nonatomic, assign) BOOL isTimeout;
@property (nonatomic, assign) BOOL isSubstitute;
@property (nonatomic, strong) CTMainViewController *home;

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



- (void)showHome {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf privacyCheckWithComplete:^{
            UIWindow *window = [weakSelf getHomeWindow];
            if (!weakSelf.home) {
                weakSelf.home = [[CTMainViewController alloc] init];
            }
            if ([window.rootViewController isKindOfClass:[CTMainViewController class]]) {
            } else {
                [window setRootViewController:weakSelf.home];
                [window makeKeyAndVisible];
            }
            weakSelf.isShowLaunch = NO;
        }];
    });
}

- (void)configureData {
    [self languageConfigure];
    [[RemoteUtil shared] requestGADConfig];
//    [CTFirebase configureAdvert];
}

- (void)showAdvert {
    [self showHome];
}
@end
