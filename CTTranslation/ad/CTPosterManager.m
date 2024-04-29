//
//  CTPosterManager.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import "CTPosterManager.h"
#import "CTFbHandle.h"
#import "NSObject+CT.h"
#import "CTBaseViewController.h"
#import <FirebaseAnalytics/FIRParameterNames.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "CTStatisticAnalysis.h"

@interface CTPosterManager () <GADBannerViewDelegate, GADNativeAdLoaderDelegate>

@property (nonatomic, strong) dispatch_queue_t adQueue;

@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) float lapo;

@property (nonatomic, strong) NSMutableArray *requestSelectLangNativeAds;
@property (nonatomic, strong) NSMutableArray *requestTranslateNativeAds;
@property (nonatomic, strong) NSMutableArray *requestSetNativeAds;
@property (nonatomic, strong) NSMutableArray *requestTranslateBannerAds;

@property (nonatomic, strong, nullable, readwrite) CTPosterModel *launchModel;
@property (nonatomic, strong, nullable) CTPosterModel *selectLangModel;
@property (nonatomic, strong, nullable) CTPosterModel *clickModel;
@property (nonatomic, strong, nullable) CTPosterModel *backModel;
@property (nonatomic, strong, nullable) CTPosterModel *translateModel;
@property (nonatomic, strong, nullable) CTPosterModel *usefulModel;
@property (nonatomic, strong, nullable) CTPosterModel *substituteModel;

@property (nonatomic, strong, nullable) CTPosterModel *selectLangNativeModel;
@property (nonatomic, strong, nullable) CTPosterModel *translateNativeModel;
@property (nonatomic, strong, nullable) CTPosterModel *setNativeModel;
@property (nonatomic, strong, nullable) CTPosterModel *translateBannerModel;

@property (nonatomic, strong) dispatch_queue_t recoQueue;
@property (nonatomic, strong) NSMutableArray *recoArray;

@end

@implementation CTPosterManager

+ (CTPosterManager *)sharedInstance {
    static CTPosterManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CTPosterManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.adQueue = dispatch_queue_create("com.co.translate.all.reco.queue", DISPATCH_QUEUE_SERIAL);
        self.recoQueue = dispatch_queue_create("com.co.translate.all.ad.queue", DISPATCH_QUEUE_CONCURRENT);
        self.recoArray = [NSMutableArray arrayWithCapacity:10];
        self.isFirst = YES;
        self.isScreenAdShow = NO;
        self.isCanShowLaunchAd = YES;
        self.lapo = 2;
    }
    return self;
}

- (void)setupWithComplete:(nullable void(^)(BOOL isSuccess))complete {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array = [[CTFirebase.remoteInfo configValueForKey:@"adconfig"] JSONValue];
        if ([array isKindOfClass:[NSArray class]] && array.count == 0) {
            if (complete) complete(NO);
            return;
        }
        
        NSArray *adLists = [weakSelf convertModelsWithArray:array];
        if (weakSelf.isFirst) {
            weakSelf.isFirst = NO;
            NSArray *models = [CTDbAdvertHandle saveDatas:adLists];
            [weakSelf setupAdModels:models];
        } else {
            [weakSelf setupAdModels:adLists];
        }
        if (complete) complete(YES);
    });
}

- (NSArray *)convertModelsWithArray:(NSArray *)array {
    NSMutableArray *adLists = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        CTPosterModel *model = [[CTPosterModel alloc] init];
        NSMutableArray *ads = [NSMutableArray arrayWithCapacity:1];
        model.name = dict[@"name"];
        model.msw = [dict[@"msw"] intValue];
        model.mck = [dict[@"mck"] intValue];
        NSArray *temps = dict[@"advertList"];
        for (NSDictionary *meta in temps) {
            CTAdInfoModel *metaModel = [[CTAdInfoModel alloc] init];
            metaModel.aid = meta[@"aid"];
            metaModel.level = [meta[@"level"] intValue];
            metaModel.type = [meta[@"type"] intValue];
            [ads addObject:metaModel];
        }
        model.advertList = ads;
        [adLists addObject:model];
    }
    return adLists;
}

- (void)setupAdModels:(NSArray *)models {
    for (CTPosterModel *model in models) {
        switch (model.posty) {
            case CTAdvertLocationTypeLaunch:
                if (self.launchModel) {
                    [self setModel:model targetModel:self.launchModel];
                } else {
                    self.launchModel = model;
                }
                break;
            case CTAdvertLocationTypeSelectLang:
                if (self.selectLangModel) {
                    [self setModel:model targetModel:self.selectLangModel];
                } else {
                    self.selectLangModel = model;
                }
                break;
            case CTAdvertLocationTypeClick:
                if (self.clickModel) {
                    [self setModel:model targetModel:self.clickModel];
                } else {
                    self.clickModel = model;
                }
                break;
            case CTAdvertLocationTypeBack:
                if (self.backModel) {
                    [self setModel:model targetModel:self.backModel];
                } else {
                    self.backModel = model;
                }
                break;
            case CTAdvertLocationTypeTranslate:
                if (self.translateModel) {
                    [self setModel:model targetModel:self.translateModel];
                } else {
                    self.translateModel = model;
                }
                break;
            case CTAdvertLocationTypeUseful:
                if (self.usefulModel) {
                    [self setModel:model targetModel:self.usefulModel];
                } else {
                    self.usefulModel = model;
                }
                break;
            case CTAdvertLocationTypeSubstitute:
                if (self.substituteModel) {
                    [self setModel:model targetModel:self.substituteModel];
                } else {
                    self.substituteModel = model;
                }
                break;
            case CTAdvertLocationTypeSelectLangNative:
                if (self.selectLangNativeModel) {
                    [self setModel:model targetModel:self.selectLangNativeModel];
                } else {
                    self.selectLangNativeModel = model;
                }
                break;
            case CTAdvertLocationTypeTranslateNative:
                if (self.translateNativeModel) {
                    [self setModel:model targetModel:self.translateNativeModel];
                } else {
                    self.translateNativeModel = model;
                }
                break;
            case CTAdvertLocationTypeSetNative:
                if (self.setNativeModel) {
                    [self setModel:model targetModel:self.setNativeModel];
                } else {
                    self.setNativeModel = model;
                }
                break;
            case CTAdvertLocationTypeTranslateBanner:
                if (self.translateBannerModel) {
                    [self setModel:model targetModel:self.translateBannerModel];
                } else {
                    self.translateBannerModel = model;
                }
                break;
            default:
                break;
        }
    }
}

- (void)setModel:(CTPosterModel *)model targetModel:(CTPosterModel *)targetModel {
    targetModel.name = model.name;
    targetModel.msw = model.msw;
    targetModel.mck = model.mck;
    targetModel.advertList = model.advertList;
}

- (void)saveAdvertDatas {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:11];
    if (self.launchModel) {
        [array addObject:self.launchModel];
    }
    if (self.selectLangModel) {
        [array addObject:self.selectLangModel];
    }
    if (self.clickModel) {
        [array addObject:self.clickModel];
    }
    if (self.backModel) {
        [array addObject:self.backModel];
    }
    if (self.translateModel) {
        [array addObject:self.translateModel];
    }
    if (self.usefulModel) {
        [array addObject:self.usefulModel];
    }
    if (self.substituteModel) {
        [array addObject:self.substituteModel];
    }
    if (self.selectLangNativeModel) {
        [array addObject:self.selectLangNativeModel];
    }
    if (self.translateNativeModel) {
        [array addObject:self.translateNativeModel];
    }
    if (self.setNativeModel) {
        [array addObject:self.setNativeModel];
    }
    if (self.translateBannerModel) {
        [array addObject:self.translateBannerModel];
    }
    
    [CTDbAdvertHandle saveDatas:array];
}

- (void)paidAdWithValue:(GADAdValue *)value {
    //上报face book
    double realValue = [value.value doubleValue];
    
    [FBSDKAppEvents.shared logPurchase:realValue currency:value.currencyCode];
}

- (void)advertLogFailedWithType:(CTAdvertLocationType)type error:(NSString *)msg {
    [self printWithModel:[self getAdvertModelWithType:type] metaModel:nil logType:CTPrintTypeShowFail extra:msg];
}

- (NSArray *)sortAds:(NSArray <CTAdInfoModel *> *)ads {
    if (ads.count > 1) {
        NSMutableArray *alls = [NSMutableArray arrayWithArray:ads];
        NSSet *set = [NSSet setWithArray:alls];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"level" ascending:NO];
        NSArray *newArray = [[set allObjects] sortedArrayUsingDescriptors:@[sort]];
        return newArray;
    } else {
        return ads;
    }
}

- (nullable id)getAdvertWithType:(CTAdvertLocationType)type {
    id ad = nil;
    switch (type) {
        case CTAdvertLocationTypeLaunch:
            ad = self.launchAd;
            break;
        case CTAdvertLocationTypeSelectLang:
            ad = self.selectLangInterstitial;
            break;
        case CTAdvertLocationTypeClick:
            ad = self.clickInterstitial;
            break;
        case CTAdvertLocationTypeBack:
            ad = self.backInterstitial;
            break;
        case CTAdvertLocationTypeTranslate:
            ad = self.translateInterstitial;
            break;
        case CTAdvertLocationTypeUseful:
            ad = self.usefulInterstitial;
            break;
        case CTAdvertLocationTypeSubstitute:
            ad = self.substituteInterstitial;
            break;
        case CTAdvertLocationTypeSelectLangNative:
            ad = self.selectLangAd;
            break;
        case CTAdvertLocationTypeTranslateNative:
            ad = self.translateAd;
            break;
        case CTAdvertLocationTypeSetNative:
            ad = self.setAd;
            break;
        default:
            break;
    }
    return ad;
}

- (nullable CTPosterModel *)getAdvertModelWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = nil;
    switch (type) {
        case CTAdvertLocationTypeLaunch:
            model = self.launchModel;
            break;
        case CTAdvertLocationTypeSelectLang:
            model = self.selectLangModel;
            break;
        case CTAdvertLocationTypeClick:
            model = self.clickModel;
            break;
        case CTAdvertLocationTypeBack:
            model = self.backModel;
            break;
        case CTAdvertLocationTypeTranslate:
            model = self.translateModel;
            break;
        case CTAdvertLocationTypeUseful:
            model = self.usefulModel;
            break;
        case CTAdvertLocationTypeSubstitute:
            model = self.substituteModel;
            break;
        case CTAdvertLocationTypeSelectLangNative:
            model = self.selectLangNativeModel;
            break;
        case CTAdvertLocationTypeTranslateNative:
            model = self.translateNativeModel;
            break;
        case CTAdvertLocationTypeSetNative:
            model = self.setNativeModel;
            break;
        case CTAdvertLocationTypeTranslateBanner:
            model = self.translateBannerModel;
            break;
        default:
            break;
    }
    return model;
}

- (void)printWithModel:(CTPosterModel *)model metaModel:(nullable CTAdInfoModel *)metaModel logType:(CTPrintType)logType extra:(nullable NSString *)extra {
#ifdef DEBUG
    NSString *message = [NSString stringWithFormat:@"\n<AD> name: '%@'%@", model.name, metaModel ? [NSString stringWithFormat:@" priority: %ld\n", metaModel.level] : @"\n"];
    switch (logType) {
        case CTPrintTypeStartLoad:
            message = [message stringByAppendingFormat:@"<AD> load info: start loading '%@' ad", model.name];
            break;
        case CTPrintTypeNotLoad:
            message = [message stringByAppendingFormat:@"<AD> load limit: '%@' ad cannot be load", model.name];
            break;
        case CTPrintTypeLoadSuccess:
            message = [message stringByAppendingFormat:@"<AD> load success: '%@' ad load Success", model.name];
            break;
        case CTPrintTypeLoadFail:
            message = [message stringByAppendingFormat:@"<AD> 请注意，这里有个错误...\n<AD> 请注意，这里有个错误...\n<AD> load error: '%@' ad load Failed", model.name];
            break;
        case CTPrintTypeShowSuccess:
            message = [message stringByAppendingFormat:@"<AD> show success: '%@' ad show Success", model.name];
            break;
        case CTPrintTypeShowFail:
            message = [message stringByAppendingFormat:@"<AD> 请注意，这里有个错误...\n<AD> 请注意，这里有个错误...\n<AD> show error: '%@' ad load Failed", model.name];
            break;
        case CTPrintTypeNotShow:
            message = [message stringByAppendingFormat:@"<AD> show limit: '%@' ad cannot be displayed", model.name];
            break;
        case CTPrintTypeHasCache:
            message = [message stringByAppendingFormat:@"<AD> cache hit: '%@' ad have cache", model.name];
            break;
        default:
            break;
    }
    if (extra.length > 0) {
        message = [message stringByAppendingFormat:@"\n<AD> %@", extra];
    }
    NSLog(@"%@", message);
#endif
}

//#pragma mark - 广告请求

- (void)syncRequestNativeAdWithType:(CTAdvertLocationType)type complete:(void(^)(BOOL isSuccess))complete {
    [self syncRequestNativeAdWithType:type timeout:20 complete:complete];
}

- (void)syncRequestNativeAdWithType:(CTAdvertLocationType)type timeout:(NSTimeInterval)timeout complete:(void(^)(BOOL isSuccess))complete {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (![self isCanShowAdvertWithType:type model:model]) {
        if (complete) complete(NO);
        return;
    }
    //判断有无缓存
    id ad = [self getAdvertWithType:type];
    if (ad && [self isCacheValidWithType:type]) {
        [self printWithModel:model metaModel:nil logType:CTPrintTypeHasCache extra:nil];
        if (complete) complete(YES);
        return;
    }
    
    BOOL isLoad = model.ild == 0 ? NO : YES;
    if (isLoad) {
        isLoad = ![self isTimeOut:model.tsld interval:20];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!isLoad) {
            [weakSelf requestNativeAdWithType:type];
        }
        //wait 20s
        int count = 0;
        BOOL isSuccess = NO;
        while (count < timeout) {
            id newAd = [weakSelf getAdvertWithType:type];
            if (newAd) {
                isSuccess = YES;
                break;
            }
            if (!model.ild) {
                break;
            }
            sleep(1);
            count += 1;
        }
        if (complete) complete(isSuccess);
    });
}

- (void)requestNativeAdWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (!model) {
        return;
    }
    if (model.ild) {
        model.ild = ![self isTimeOut:model.tsld interval:20];
    }
    if (model.ild) return;
    if ([self getAdvertWithType:model.posty] && [self isCacheValidWithType:model.posty]) {
        [self printWithModel:model metaModel:nil logType:CTPrintTypeHasCache extra:nil];
        return;
    }
    
    [self setupIsLoad:YES type:model.posty];
    NSArray <CTAdInfoModel *> *ads = model.advertList;
    if (model.advertList.count > 1) {
        ads = [self sortAds:model.advertList];
    }
    CTAdInfoModel *ad = ads.firstObject;
    switch (ad.type) {
        case CTAdvertTypeNative: {
            if (model.posty == CTAdvertLocationTypeSelectLangNative) {
                self.requestSelectLangNativeAds = [NSMutableArray arrayWithArray:ads];
                [self requestNativeAdWithModel:model metaModel:ad];
            } else if (model.posty == CTAdvertLocationTypeTranslateNative) {
                self.requestTranslateNativeAds = [NSMutableArray arrayWithArray:ads];
                [self requestNativeAdWithModel:model metaModel:ad];
            } else if (model.posty == CTAdvertLocationTypeSetNative) {
                self.requestSetNativeAds = [NSMutableArray arrayWithArray:ads];
                [self requestNativeAdWithModel:model metaModel:ad];
            }
            break;
        }
//        case CTAdvertTypeBanner:
//            break;
        default:
            break;
    }
}

- (void)requestNativeAdWithModel:(CTPosterModel *)model metaModel:(CTAdInfoModel *)ad {
//    GADMultipleAdsAdLoaderOptions *multipleAdsOptions =
//        [[GADMultipleAdsAdLoaderOptions alloc] init];
//    multipleAdsOptions.numberOfAds = 5;
    GADAdLoader *adLoader = [[GADAdLoader alloc] initWithAdUnitID:ad.aid rootViewController:nil adTypes:@[GADAdLoaderAdTypeNative] options:nil];
    adLoader.delegate = self;
    [self printWithModel:model metaModel:ad logType:CTPrintTypeStartLoad extra:nil];
    [adLoader loadRequest:[GADRequest request]];
    if (model.posty == CTAdvertLocationTypeSelectLangNative) {
        self.selectLangLoader = adLoader;
    } else if (model.posty == CTAdvertLocationTypeTranslateNative) {
        self.translateLoader = adLoader;
    } else if (model.posty == CTAdvertLocationTypeSetNative) {
        self.setLoader = adLoader;
    }
}

- (void)syncRequestScreenAdWithType:(CTAdvertLocationType)type timeout:(NSTimeInterval)timeout complete:(void(^)(BOOL isSuccess))complete {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (![self isCanShowAdvertWithType:type model:model]) {
        if (complete) complete(NO);
        return;
    }
    
    id ad = [self getAdvertWithType:type];
    if (ad && [self isCacheValidWithType:type]) {
        [self printWithModel:model metaModel:nil logType:CTPrintTypeHasCache extra:nil];
        if (complete) complete(YES);
        return;
    }
    
    BOOL isLoad = model.ild;
    if (isLoad) {
        isLoad = ![self isTimeOut:model.tsld interval:20];
    }
    
    __block BOOL isComplete = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (isLoad) {
            //wait 20s
            int count = 0;
            BOOL isSuccess = NO;
            while (count < timeout) {
                id newAd = [weakSelf getAdvertWithType:type];
                if (newAd) {
                    isSuccess = YES;
                    break;
                }
                
                if (!model.ild) {
                    break;
                }
                sleep(1);
                count += 1;
            }
            if (complete) complete(isSuccess);
        } else {
            BOOL isSuccess = NO;
            isSuccess = [weakSelf syncRequestScreenAdWithModel:model];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isComplete) {
                    isComplete = YES;
                    if (complete) complete(isSuccess);
                }
            });
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isComplete) {
            isComplete = YES;
            if (complete) complete(NO);
        }
    });
}

- (BOOL)syncRequestScreenAdWithModel:(CTPosterModel *)model {
    [self setupIsLoad:YES type:model.posty];
    NSArray <CTAdInfoModel *> *ads = model.advertList;
    if (model.advertList.count > 1) {
        ads = [self sortAds:model.advertList];
    }
    __block BOOL isSuccess = NO;
    __weak typeof(self) weakSelf = self;
    for (CTAdInfoModel *ad in ads) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        switch (ad.type) {
            case CTAdvertTypeInterstitial: {
                [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeStartLoad extra:nil];
                [weakSelf requestInterstitialAd:model infoModel:ad complete:^(GADInterstitialAd *ad) {
                    if (ad)  {
                        isSuccess = YES;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                break;
            }
            case CTAdvertTypeOpen: {
                [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeStartLoad extra:nil];
                [weakSelf requestOpenAd:model infoModel:ad complete:^(GADAppOpenAd *ad) {
                    if (ad) {
                        isSuccess = YES;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                break;
            }
            default:
                dispatch_semaphore_signal(semaphore);
                break;
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (isSuccess) break;
    }
    [self setupIsLoad:NO type:model.posty];
    if (model.posty == CTAdvertLocationTypeLaunch) {
        [self handleLaunchAd];
    }
    return isSuccess;
}

- (void)requestScreenAdWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (![self isCanLoadAdvertWithType:model.posty]) {
        return;
    }
    [self setupIsLoad:YES type:model.posty];
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.adQueue, ^{
        NSArray <CTAdInfoModel *> *ads = model.advertList;
        if (model.advertList.count > 1) {
            ads = [weakSelf sortAds:model.advertList];
        }
        
        for (CTAdInfoModel *ad in ads) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
             __block BOOL isSuccess = NO;
            switch (ad.type) {
                case CTAdvertTypeInterstitial: {
                    [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeStartLoad extra:nil];
                    [weakSelf requestInterstitialAd:model infoModel:ad complete:^(GADInterstitialAd *ad) {
                        if (ad)  {
                            isSuccess = YES;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }];
                    break;
                }
                case CTAdvertTypeOpen: {
                    [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeStartLoad extra:nil];
                    [weakSelf requestOpenAd:model infoModel:ad complete:^(GADAppOpenAd *ad) {
                        if (ad) {
                            isSuccess = YES;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }];
                    break;
                }
                default:
                    dispatch_semaphore_signal(semaphore);
                    break;
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (isSuccess) break;
        }
        [weakSelf setupIsLoad:NO type:model.posty];
        if (model.posty == CTAdvertLocationTypeLaunch) {
            [weakSelf handleLaunchAd];
        }
    });
}

- (void)handleLaunchAd {
    if (self.launchAd) {
        self.lapo = 2;
    } else {
        self.lapo += 1;
        float time = powf(2, self.lapo);
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestLaunchAd];
        });
    }
}

- (void)requestLaunchAd {
    [self requestScreenAdWithType:CTAdvertLocationTypeLaunch];
}

- (void)requestOpenAd:(CTPosterModel *)model infoModel:(CTAdInfoModel *)ad complete:(void(^)(GADAppOpenAd *ad))complete {
    
    NSString *adid = ad.aid;
    if (self.launchAd && [self isCacheValidWithType:model.posty]) {
        [self printWithModel:model metaModel:ad logType:CTPrintTypeHasCache extra:nil];
        complete(self.launchAd);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [GADAppOpenAd loadWithAdUnitID:adid request:[GADRequest request] orientation:UIInterfaceOrientationPortrait completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
        if (error) {
            [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeLoadFail extra:[NSString stringWithFormat:@"reason => %@", [error localizedDescription]]];
            if (complete) complete(nil);
            return;
        }
        weakSelf.launchAd = appOpenAd;
        [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeLoadSuccess extra:nil];
//        __weak typeof(appOpenAd) weakAd = appOpenAd;
//        appOpenAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            __strong typeof(weakAd) strongAd = weakAd;
//            [strongSelf paidAdWithValue:value ad:strongAd];
//        };
        if (complete) complete(appOpenAd);
  }];
}

- (void)requestInterstitialAd:(CTPosterModel *)model infoModel:(CTAdInfoModel *)ad complete:(void(^)(GADInterstitialAd *ad))complete {
    //判断缓存情况
    CTAdvertLocationType type = model.posty;
    NSString *adid = ad.aid;
    GADInterstitialAd *cacheAd = [self getAdvertWithType:type];
    
    if (cacheAd && [self isCacheValidWithType:model.posty]) {
        [self printWithModel:model metaModel:ad logType:CTPrintTypeHasCache extra:nil];
        if (complete) complete(cacheAd);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [GADInterstitialAd loadWithAdUnitID:adid request:[GADRequest request] completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
        if (error) {
            [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeLoadFail extra:[NSString stringWithFormat:@"reason => %@", [error localizedDescription]]];
            if (complete) complete(nil);
          return;
        }
        
        switch (type) {
            case CTAdvertLocationTypeLaunch:
                self.launchAd = interstitialAd;
                break;
            case CTAdvertLocationTypeSelectLang:
                self.selectLangInterstitial = interstitialAd;
                break;
            case CTAdvertLocationTypeClick:
                self.clickInterstitial = interstitialAd;
                break;
            case CTAdvertLocationTypeBack:
                self.backInterstitial = interstitialAd;
                break;
            case CTAdvertLocationTypeTranslate:
                self.translateInterstitial = interstitialAd;
                break;
            case CTAdvertLocationTypeUseful:
                self.usefulInterstitial = interstitialAd;
                break;
            case CTAdvertLocationTypeSubstitute:
                self.substituteInterstitial = interstitialAd;
                break;
            default:
                break;
        }
        [weakSelf printWithModel:model metaModel:ad logType:CTPrintTypeLoadSuccess extra:nil];
//        interstitialAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf paidAdWithValue:value];
//        };
        
        [weakSelf setupTldWithType:type];
        if (complete) complete(interstitialAd);
    }];
}

- (GADBannerView *)requestAdWithBannerType:(CTAdvertLocationType)type vc:(UIViewController *)vc {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (![self isCanLoadAdvertWithType:type model:model]) {
        if (type == CTAdvertLocationTypeTranslateBanner) {
            self.translateBannerView.rootViewController = vc;
            return self.translateBannerView;
        }
        return nil;
    }
    
    if (type == CTAdvertLocationTypeTranslateBanner) {
        if (self.translateBannerView == nil) {
            self.translateBannerView = [[GADBannerView alloc] init];
            self.translateBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.mainScreen.bounds.size.width);
        }
        self.translateBannerView.delegate = self;
        self.translateBannerView.rootViewController = vc;
        self.requestTranslateBannerAds = [NSMutableArray arrayWithArray:[self sortAds:model.advertList]];
        CTAdInfoModel *infoModel = self.requestTranslateBannerAds.firstObject;
        [self requestAdWithBannerView:self.translateBannerView model:model metaModel:infoModel];
        return self.translateBannerView;
    }
    return nil;
}

- (void)requestAdWithBannerView:(GADBannerView *)bannerView model:(CTPosterModel *)model metaModel:(CTAdInfoModel *)infoModel {
    bannerView.adUnitID = infoModel.aid;
    GADRequest *request = [GADRequest request];
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"collapsible" : @"top"};
    [request registerAdNetworkExtras:extras];
    [self printWithModel:model metaModel:infoModel logType:CTPrintTypeStartLoad extra:nil];
    [self setupIsLoad:YES type:model.posty];
    
    [bannerView loadRequest:request];
    
    __weak typeof(self) weakSelf = self;
    bannerView.paidEventHandler = ^(GADAdValue * _Nonnull value) {
        [weakSelf paidAdWithValue:value];
    };
}

- (CTAdvertLocationType)bannerType:(GADBannerView *)bannerView {
    if (bannerView == self.translateBannerView) {
        return CTAdvertLocationTypeTranslateBanner;
    }
    return CTAdvertLocationTypeUnknow;
}
//#pragma mark - model更新和状态检查

- (void)setupCckWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    model.cck += 1;
}

- (void)setupCswWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    [self printWithModel:model metaModel:nil logType:CTPrintTypeShowSuccess extra:nil];
    //更新展示次数，正在展示和展示时间三个字段
    model.csw += 1;
    model.tsw = [[NSDate date] timeIntervalSince1970];
    model.isw = YES;
}

- (void)setupIsShow:(BOOL)isShow type:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    model.isw = isShow;
}

- (void)setupIsLoad:(BOOL)isLoad type:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    model.ild = isLoad;
    if (isLoad == 1) {
        model.tsld = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)setupTldWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    model.tld = [[NSDate date] timeIntervalSince1970];
}

- (BOOL)isCanLoadAdvertWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    return [self isCanLoadAdvertWithType:type model:model];
}

- (BOOL)isCanLoadAdvertWithType:(CTAdvertLocationType)type model:(CTPosterModel *)model {
    BOOL isLoad = model.ild;
    if (model.ild) {
        isLoad = ![self isTimeOut:model.tsld interval:20];
    }
    
    if ((model == nil) || model.isw || isLoad || (model.csw >= model.msw) || (model.cck >= model.mck)) {
        [self printWithModel:[self getAdvertModelWithType:type] metaModel:nil logType:CTPrintTypeNotLoad extra:[NSString stringWithFormat:@"reason => name:%@ isShow:%d isLoad:%d currentShow/maxShow:%d/%d currentClick/maxClick:%d/%d", model.name, model.isw, isLoad, model.csw, model.msw, model.cck, model.mck]];
        return NO;
    }
    
    //判断是否是激进模式
    if (type == CTAdvertLocationTypeSelectLang || type == CTAdvertLocationTypeClick || type == CTAdvertLocationTypeBack || type == CTAdvertLocationTypeUseful) {
        NSString *userModel = [CTFirebase getAppMode];
        if ([userModel isEqualToString:@"b"]) {
            [self printWithModel:[self getAdvertModelWithType:type]  metaModel:nil logType:CTPrintTypeNotLoad extra:[NSString stringWithFormat:@"reason => name:%@ userModel:%@", model.name, userModel]];
            return NO;
        }
    }
    return YES;
}

- (BOOL)isCanShowAdvertWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    return [self isCanShowAdvertWithType:type model:model];
}

- (BOOL)isCanShowAdvertWithType:(CTAdvertLocationType)type model:(CTPosterModel *)model {
    if ((model == nil) || model.isw || (model.csw >= model.msw) || (model.cck >= model.mck)) {
        [self printWithModel:[self getAdvertModelWithType:type]  metaModel:nil logType:CTPrintTypeNotShow extra:[NSString stringWithFormat:@"reason => name:%@ isShow:%d currentShow/maxShow:%d/%d currentClick/maxClick:%d/%d", model.name, model.isw, model.csw, model.msw, model.cck, model.mck]];
        return NO;
    }
    
    //判断是否是激进模式
    if (type == CTAdvertLocationTypeSelectLang || type == CTAdvertLocationTypeClick || type == CTAdvertLocationTypeBack || type == CTAdvertLocationTypeUseful) {
        NSString *userModel = [CTFirebase getAppMode];
        if ([userModel isEqualToString:@"b"]) {
            [self printWithModel:[self getAdvertModelWithType:type]  metaModel:nil logType:CTPrintTypeNotShow extra:[NSString stringWithFormat:@"reason => name:%@ userModel:%@", model.name, userModel]];
            return NO;
        }
    }
    
    //判断是否在后台
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self printWithModel:[self getAdvertModelWithType:type]  metaModel:nil logType:CTPrintTypeNotShow extra:[NSString stringWithFormat:@"reason => name:%@, The application is not in an active state", model.name]];
        return NO;
    }
    return YES;
}

- (BOOL)isShowLimt:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (model == nil) {
        return YES;
    }
    
    if (model.csw >= model.msw) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isTimeOut:(NSTimeInterval)time interval:(NSTimeInterval)interval {
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeInterval = fabs(date - time);
    if (timeInterval > interval) {
        return YES;
    } else {
        return NO;
    }
}

//判断缓存是否有效
- (BOOL)isCacheValidWithType:(CTAdvertLocationType)type {
    CTPosterModel *model = [self getAdvertModelWithType:type];
    if (model.tld != 0) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timeInterval = fabs(time - model.tld);
        if (timeInterval > 3000) {
            return NO;
        }
    }
    return YES;
}

- (void)resetAdLoad {
    self.selectLangModel.ild = false;
    self.clickModel.ild = false;
    self.backModel.ild = false;
    self.translateModel.ild = false;
    self.usefulModel.ild = false;
    self.substituteModel.ild = false;
    self.translateNativeModel.ild = false;
    self.setNativeModel.ild = false;
    self.selectLangNativeModel.ild = false;
}

- (BOOL)resetAdShow {
    BOOL hasShow = NO;
    if (self.selectLangModel.isw) {
        self.selectLangModel.isw = false;
        hasShow = YES;
    }
    if (self.clickModel.isw) {
        self.clickModel.isw = false;
        hasShow = YES;
    }
    if (self.backModel.isw) {
        self.backModel.isw = false;
        hasShow = YES;
    }
    if (self.translateModel.isw) {
        self.translateModel.isw = false;
        hasShow = YES;
    }
    if (self.usefulModel.isw) {
        self.usefulModel.isw = false;
        hasShow = YES;
    }
    if (self.substituteModel.isw) {
        self.substituteModel.isw = false;
        hasShow = YES;
    }
    if (self.translateNativeModel.isw) {
        self.translateNativeModel.isw = false;
    }
    if (self.setNativeModel.isw) {
        self.setNativeModel.isw = false;
    }
    if (self.selectLangNativeModel.isw) {
        self.selectLangNativeModel.isw = false;
    }
    return hasShow;
}

//TODO: bannerDelegate
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    //接收到bannerad数据
    CTAdvertLocationType type = [self bannerType:bannerView];
    [self setupIsLoad:NO type:type];
    if (type == CTAdvertLocationTypeTranslateBanner) {
        [self printWithModel:[self getAdvertModelWithType:type] metaModel:self.requestTranslateBannerAds.firstObject logType:CTPrintTypeLoadSuccess extra:nil];
        self.requestTranslateBannerAds = nil;
    }
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  //添加展示次数?
    [[CTPosterManager sharedInstance] setupCswWithType:CTAdvertLocationTypeTranslateBanner];
    [CTStatisticAnalysis saveEvent:@"gag_show" params:@{@"place": @"banner"}];
}

- (void)bannerViewDidRecordClick:(nonnull GADBannerView *)bannerView {
    //点击
    CTAdvertLocationType type = [self bannerType:bannerView];
    [self setupCckWithType:type];
}

- (void)bannerView:(nonnull GADBannerView *)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error {
    CTAdInfoModel *model = nil;
    CTAdvertLocationType type = [self bannerType:bannerView];
    CTPosterModel *adModel = [self getAdvertModelWithType:type];
    if (type == CTAdvertLocationTypeTranslateBanner) {
        [self printWithModel:adModel metaModel:self.requestTranslateBannerAds.firstObject logType:CTPrintTypeLoadFail extra:[NSString stringWithFormat:@"reason:%@", error.localizedDescription]];
        if (self.requestTranslateBannerAds.count > 1) {
            [self.requestTranslateBannerAds removeObjectAtIndex:0];
            model = self.requestTranslateBannerAds.firstObject;
        } else {
            [self setupIsLoad:NO type:type];
            self.requestTranslateBannerAds = nil;
        }
    }
    
    [self advertLogFailedWithType:type error:error.localizedDescription];
    if (model) {
        [self requestAdWithBannerView:bannerView model:adModel metaModel:model];
    }
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
//    nativeAd.delegate = self;
    CTAdvertLocationType type = CTAdvertLocationTypeUnknow;
    if (adLoader == self.translateLoader) {
        self.translateAd = nativeAd;
        type = CTAdvertLocationTypeTranslateNative;
        [self printWithModel:[self getAdvertModelWithType:type] metaModel:((CTAdInfoModel *)self.requestTranslateNativeAds.firstObject) logType:CTPrintTypeLoadSuccess extra:nil];
        self.requestTranslateNativeAds = nil;
        
    } else if (adLoader == self.selectLangLoader) {
        self.selectLangAd = nativeAd;
        type = CTAdvertLocationTypeSelectLangNative;
        [self printWithModel:[self getAdvertModelWithType:type] metaModel:((CTAdInfoModel *)self.requestSelectLangNativeAds.firstObject) logType:CTPrintTypeLoadSuccess extra:nil];
        self.requestSelectLangNativeAds = nil;
        
    } else if (adLoader == self.setLoader) {
        self.setAd = nativeAd;
        type = CTAdvertLocationTypeSetNative;
        [self printWithModel:[self getAdvertModelWithType:type] metaModel:((CTAdInfoModel *)self.requestSetNativeAds.firstObject) logType:CTPrintTypeLoadSuccess extra:nil];
        self.requestSetNativeAds = nil;
        
    }
    [self setupTldWithType:type];
    [self setupIsLoad:NO type:type];
}


- (void)adLoader:(nonnull GADAdLoader *)adLoader didFailToReceiveAdWithError:(nonnull NSError *)error {
    CTAdvertLocationType type = CTAdvertLocationTypeUnknow;
    CTAdInfoModel *model = nil;
    if (adLoader == self.translateLoader) {
        type = CTAdvertLocationTypeTranslateNative;
        if (self.requestTranslateNativeAds.count > 1) {
            [self.requestTranslateNativeAds removeObjectAtIndex:0];
            model = self.requestTranslateNativeAds.firstObject;
        } else {
            [self setupIsLoad:NO type:type];
            self.requestTranslateNativeAds = nil;
        }
    } else if (adLoader == self.selectLangLoader) {
        type = CTAdvertLocationTypeSelectLangNative;
        if (self.requestSelectLangNativeAds.count > 1) {
            [self.requestSelectLangNativeAds removeObjectAtIndex:0];
            model = self.requestSelectLangNativeAds.firstObject;
        } else {
            [self setupIsLoad:NO type:type];
            self.requestSelectLangNativeAds = nil;
        }
    } else if (adLoader == self.setLoader) {
        type = CTAdvertLocationTypeSetNative;
        if (self.requestSetNativeAds.count > 1) {
            [self.requestSetNativeAds removeObjectAtIndex:0];
            model = self.requestSetNativeAds.firstObject;
        } else {
            [self setupIsLoad:NO type:type];
            self.requestSetNativeAds = nil;
        }
    }
    
    CTPosterModel *adModel = [[CTPosterManager sharedInstance] getAdvertModelWithType:type];
    [self printWithModel:adModel metaModel:model logType:CTPrintTypeLoadFail extra:[NSString stringWithFormat:@"reason => %@", [error localizedDescription]]];
    
    if (model) {
        [self requestNativeAdWithModel:adModel metaModel:model];
    }
}

#pragma mark - 页面进入和埋点相关

- (void)enterLaunch {
    [self addReco:@"load"];
    NSString *userModel = [CTFirebase getAppMode];
    if ([userModel isEqualToString:@"j"]) {
        NSString *text = [[NSUserDefaults standardUserDefaults] stringForKey:@"showChoosevc"];
        if (text == 0) {
            [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeSelectLang];
            [[CTPosterManager sharedInstance] requestNativeAdWithType:CTAdvertLocationTypeSelectLangNative];
        }
        [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeClick];
    }
    [[CTPosterManager sharedInstance] requestNativeAdWithType:CTAdvertLocationTypeTranslateNative];
    [[CTPosterManager sharedInstance] requestNativeAdWithType:CTAdvertLocationTypeSetNative];
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeTranslate];
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeSubstitute];
}

- (void)enterForeground {
    UIViewController *vc = [NSObject getCurrentTopVC];
    if ([vc isKindOfClass:[CTBaseViewController class]]) {
        CTBaseViewController *basevc = (CTBaseViewController *)vc;
        [basevc didVC];
    }
}

- (void)enterHome {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeClick];
    [[CTPosterManager sharedInstance] requestNativeAdWithType:CTAdvertLocationTypeTranslateNative];
    [[CTPosterManager sharedInstance] requestNativeAdWithType:CTAdvertLocationTypeSetNative];
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeTranslate];
}

- (void)jumpHome {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeBack];
}

- (void)enterChooseLang {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeSelectLang];
    [[CTPosterManager sharedInstance] requestNativeAdWithType:CTAdvertLocationTypeSelectLangNative];
}

- (void)enterText {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeTranslate];
}

- (void)enterVoice {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeTranslate];
}

- (void)enterCamera {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeTranslate];
}

- (void)enterUseful {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeUseful];
}

- (void)enterSubstitute {
    [[CTPosterManager sharedInstance] requestScreenAdWithType:CTAdvertLocationTypeSubstitute];
}

- (void)enterBackgroud {
    [self addReco:@"back"];
}

- (void)addReco:(NSString *)reco {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.recoQueue, ^{
        [weakSelf.recoArray addObject:reco];
        if (weakSelf.recoArray.count > 8) {
            [weakSelf.recoArray removeObjectAtIndex:0];
        }
        NSString *string = [weakSelf.recoArray componentsJoinedByString:@"-"];
        [CTStatisticAnalysis saveEvent:@"use_reco" params:@{@"reco": string}];
    });
}

@end
