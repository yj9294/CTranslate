//
//  SceneDelegate.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/25.
//

#import "SceneDelegate.h"
#import "CTLaunchViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIView+CT.h"
#import "NSObject+CT.h"
#import "CTTanslatePrivacyPop.h"
#import "CTTranslateManager.h"
#import "CTStatisticAnalysis.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <VungleAdsSDK/VungleAdsSDK.h>
#import <MTGSDK/MTGSDK.h>
#import <UnityAds/UnityAds.h>
#import <FBAudienceNetwork/FBAdSettings.h>
#import <FBAudienceNetwork/FBAdSettings.h>
@import AppTrackingTransparency;
@import FirebaseCore;
@import IQKeyboardManager;
@import AFNetworking;
@import MLKit;

@interface SceneDelegate ()
@property (nonatomic, strong) CTLaunchViewController *launchVC;
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    self.window = [[UIWindow alloc] init];
    [self.window setBackgroundColor:[UIColor hexColor:@"#202329"]];
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    [self.window setWindowScene:windowScene];
    [self.window makeKeyAndVisible];

    [self networkManager];
    [self configureData];
    
    [[IQKeyboardManager sharedManager] setShouldShowToolbarPlaceholder:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    [[UITableView appearance] setEstimatedRowHeight:0];
    [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    [[UITableView appearance] setEstimatedSectionFooterHeight:0];
    [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    
    self.window.rootViewController = self.launchVC;
    [AppManager shared].window = self.window;
}

#pragma mark - cycle

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    UIViewController *vc = [self getCurrentTopVC];
    if ([vc isKindOfClass:[NSClassFromString(@"GADFullScreenAdViewController") class]]) {
        AppManager.shared.isDismissFullAd = YES;
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    __weak typeof(self) weakSelf = self;
    [self privacyCheckWithComplete:^{
        [weakSelf idfaCheckWithComplete:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.launchVC launch];
            });
        }];
    }];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    UIViewController *vc = [self getCurrentTopVC];
    if ([vc isKindOfClass:[NSClassFromString(@"GADFullScreenAdViewController") class]]) {
        AppManager.shared.isDismissFullAd = YES;
        [vc dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    if (url) {
        [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] openURL:url sourceApplication:nil annotation:@[UIApplicationOpenURLOptionsAnnotationKey]];
    }
}


- (void)networkManager {
    __weak typeof(self) weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status > 0) {
            [weakSelf configureData];
            // 有网加载广告
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)configureData {
    MLKTranslateLanguage language = MLKTranslateLanguageChinese;
    if (![CTTranslateManager hasModelWithLanguage:language]) {
        [CTTranslateManager downloadWithLanguage:language complete:^(BOOL isSuccess) {
            
        }];
    }
    [[RemoteUtil shared] requestGADConfig];
}

- (void)privacyCheckWithComplete:(void(^)(void))complete {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

- (CTLaunchViewController *)launchVC {
    if (!_launchVC) {
        _launchVC = [[CTLaunchViewController alloc] init];
    }
    return _launchVC;
}

- (void)addGADNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gadShow:) name:@"ad.impression" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gadClick:) name:@"ad.click" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gadPaid:) name:@"ad.paid" object:nil];
}

- (void)gadShow:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": [model getSceneName]}];
}

- (void)gadClick:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    [CTStatisticAnalysis saveEvent:@"gag_click" params:@{@"place": [model getSceneName]}];
}

- (void)gadPaid: (NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    [GADUtil.shared addPriceWithPrice:model.price currency:model.currency];
}

- (void)configGAD {
    
    //AppLovin
    [ALPrivacySettings setHasUserConsent:YES];
    [ALPrivacySettings setDoNotSell:YES];
    
    ironSource
    [IronSource setConsent:YES];
    [IronSource setMetaDataWithKey:@"do_not_sell" value:@"YES"];
    
    Liftoff
    [VunglePrivacySettings setGDPRStatus:YES];
    [VunglePrivacySettings setGDPRMessageVersion:@"v1.0.0"];
    [VunglePrivacySettings setCCPAStatus:YES];
    
    
    Mintegral
    [[MTGSDK sharedInstance] setConsentStatus:YES];
    [[MTGSDK sharedInstance] setDoNotTrackStatus:NO];
    
    Pangle 不需要设置
    
    Unity
    UADSMetaData *gdprMetaData = [[UADSMetaData alloc] init];
    [gdprMetaData set:@"gdpr.consent" value:@YES];
    [gdprMetaData commit];
    UADSMetaData *ccpaMetaData = [[UADSMetaData alloc] init];
    [ccpaMetaData set:@"privacy.consent" value:@YES];
    [ccpaMetaData commit];
}

@end
