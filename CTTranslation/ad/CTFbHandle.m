//
//  CTFbHandle.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/29.
//

#import "CTFbHandle.h"
#import <FirebaseAnalytics/FirebaseAnalytics.h>
#import <FirebaseCore/FirebaseCore.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "CTPosterManager.h"
#import <FBAudienceNetwork/FBAdSettings.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CTStatisticAnalysis.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <VungleAdsSDK/VungleAdsSDK.h>
#import <MTGSDK/MTGSDK.h>
#import <UnityAds/UnityAds.h>
#import <FBAudienceNetwork/FBAdSettings.h>

@interface CTFbHandle ()

@property (nonatomic, strong, readwrite) FIRRemoteConfig *remoteInfo;
@property (nonatomic, assign) BOOL isAdConfig;
@property (nonatomic, strong) NSString *mode;

@end

@implementation CTFbHandle

+ (CTFbHandle *)shared {
    static CTFbHandle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CTFbHandle alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isAdConfig = NO;
        [FIRApp configure];
    }
    return self;
}

- (void)configreRemoteInfo {
    self.remoteInfo = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *setting = [[FIRRemoteConfigSettings alloc] init];
#ifdef DEBUG
    setting.minimumFetchInterval = 0;
#endif
    self.remoteInfo.configSettings = setting;
    [self.remoteInfo setDefaultsFromPlistFileName:@"remote_config_defaults"];
}

- (void)configureAdvert {
    if (self.isAdConfig) {
        return;
    }
    self.isAdConfig = YES;
    
    //AppLovin
    [ALPrivacySettings setHasUserConsent:YES];
    [ALPrivacySettings setDoNotSell:YES];
    
    //ironSource
//    [IronSource setConsent:YES];
//    [IronSource setMetaDataWithKey:@"do_not_sell" value:@"YES"];
    
    //Liftoff
    [VunglePrivacySettings setGDPRStatus:YES];
    [VunglePrivacySettings setGDPRMessageVersion:@"v1.0.0"];
    [VunglePrivacySettings setCCPAStatus:YES];
    
    //ad
    if (@available(iOS 14, *)) {
        if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized) {
            [self setTrackingWithEnabled:YES];
        } else {
            [self setTrackingWithEnabled:NO];
        }
    } else {
        [self setTrackingWithEnabled:YES];
    }
    
    //Mintegral
    [[MTGSDK sharedInstance] setConsentStatus:YES];
    [[MTGSDK sharedInstance] setDoNotTrackStatus:NO];
    
    //Pangle 不需要设置
    
    //Unity
    UADSMetaData *gdprMetaData = [[UADSMetaData alloc] init];
    [gdprMetaData set:@"gdpr.consent" value:@YES];
    [gdprMetaData commit];
    UADSMetaData *ccpaMetaData = [[UADSMetaData alloc] init];
    [ccpaMetaData set:@"privacy.consent" value:@YES];
    [ccpaMetaData commit];
    
    [self startAdmob];
}

- (void)setTrackingWithEnabled:(BOOL)enabled {
    [FBSDKSettings sharedSettings].isAdvertiserTrackingEnabled = enabled;
    [FBAdSettings setAdvertiserTrackingEnabled:enabled];
}

- (void)startAdmob {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
}

// 激进:j 保守:b
- (NSString *)getAppMode {
    NSString *model = [[self.remoteInfo configValueForKey:@"yong"] stringValue];
    if (model.length == 0) {
        model = @"b";
    }
    return model;
}

- (NSInteger)getGuid {
    NSInteger guid = [[[self.remoteInfo configValueForKey:@"guid"] numberValue] integerValue];
    return guid;
}

- (NSArray *)getRecommendList {
    id obj = [[self.remoteInfo configValueForKey:@"recommend"] JSONValue];
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    return @[];
}

- (void)appInfoWithComplete:(void(^)(BOOL isSuccess, id config))complete {
    __weak typeof(self) weakSelf = self;
    [self.remoteInfo fetchAndActivateWithCompletionHandler:^(FIRRemoteConfigFetchAndActivateStatus status, NSError * _Nullable error) {
        if (status != FIRRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote) {
            NSLog(@"<Config> config fetch field:%@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(NO, nil);
            });
        } else {
            id obj = [[weakSelf.remoteInfo configValueForKey:@"adconfig"] JSONValue];
//            NSArray *array = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(YES, obj);
            });
        }
    }];
}

@end
