//
//  CTPosterManager.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import <Foundation/Foundation.h>
#import "CTPosterModel.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "CTDbAdvertHandle.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTPrintType) {
    CTPrintTypeStartLoad = 0, //开始加载
    CTPrintTypeNotLoad, //不能加载
    CTPrintTypeLoadSuccess, //加载成功
    CTPrintTypeLoadFail, //加载失败
    CTPrintTypeShowSuccess, //显示成功
    CTPrintTypeShowFail, //显示失败
    CTPrintTypeNotShow, //不能显示
    CTPrintTypeHasCache, //有缓存
    
};

@interface CTPosterManager : NSObject

@property (nonatomic, strong, nullable) GADAdLoader *selectLangLoader;
@property (nonatomic, strong, nullable) GADNativeAd *selectLangAd;
@property (nonatomic, strong, nullable) GADAdLoader *translateLoader;
@property (nonatomic, strong, nullable) GADNativeAd *translateAd;
@property (nonatomic, strong, nullable) GADAdLoader *setLoader;
@property (nonatomic, strong, nullable) GADNativeAd *setAd;

@property (nonatomic, strong, nullable) GADBannerView *translateBannerView;

@property (nonatomic, strong, nullable) id launchAd;
@property (nonatomic, strong, nullable) GADInterstitialAd *selectLangInterstitial;
@property (nonatomic, strong, nullable) GADInterstitialAd *clickInterstitial;
@property (nonatomic, strong, nullable) GADInterstitialAd *backInterstitial;
@property (nonatomic, strong, nullable) GADInterstitialAd *translateInterstitial;
@property (nonatomic, strong, nullable) GADInterstitialAd *usefulInterstitial;
@property (nonatomic, strong, nullable) GADInterstitialAd *substituteInterstitial;

@property (nonatomic, strong, nullable, readonly) CTPosterModel *launchModel;

//是否有全屏广告在展示
@property (atomic, assign) BOOL isScreenAdShow;
@property (atomic, assign) BOOL isCanShowLaunchAd;

+ (CTPosterManager *)sharedInstance;
- (void)setupWithComplete:(nullable void(^)(BOOL isSuccess))complete;
- (void)saveAdvertDatas;

- (void)setupCckWithType:(CTAdvertLocationType)type;
- (void)setupCswWithType:(CTAdvertLocationType)type;
- (void)setupIsShow:(BOOL)isShow type:(CTAdvertLocationType)type;
- (void)setupIsLoad:(BOOL)isLoad type:(CTAdvertLocationType)type;

- (BOOL)isCanShowAdvertWithType:(CTAdvertLocationType)type;
- (BOOL)isCanLoadAdvertWithType:(CTAdvertLocationType)type;
- (BOOL)isShowLimt:(CTAdvertLocationType)type;
- (BOOL)isCacheValidWithType:(CTAdvertLocationType)type;
- (BOOL)isTimeOut:(NSTimeInterval)time interval:(NSTimeInterval)interval;

- (GADBannerView *)requestAdWithBannerType:(CTAdvertLocationType)type vc:(UIViewController *)vc;
- (void)requestLaunchAd;
- (void)requestScreenAdWithType:(CTAdvertLocationType)type;
- (void)syncRequestScreenAdWithType:(CTAdvertLocationType)type timeout:(NSTimeInterval)timeout complete:(void(^)(BOOL isSuccess))complete;
- (void)syncRequestNativeAdWithType:(CTAdvertLocationType)type complete:(void(^)(BOOL isSuccess))complete;
- (void)requestNativeAdWithType:(CTAdvertLocationType)type;

- (void)resetAdLoad;
- (BOOL)resetAdShow;

- (nullable CTPosterModel *)getAdvertModelWithType:(CTAdvertLocationType)type;
- (void)paidAdWithValue:(GADAdValue *)value;
- (void)advertLogFailedWithType:(CTAdvertLocationType)type error:(NSString *)msg;

- (NSArray *)sortAds:(NSArray <CTAdInfoModel *> *)ads;

- (void)printWithModel:(CTPosterModel *)model metaModel:(nullable CTAdInfoModel *)metaModel logType:(CTPrintType)logType extra:(nullable NSString *)extra;

//进入或回到对应界面需要进行的处理
- (void)enterLaunch;
- (void)enterForeground;
- (void)enterHome;
- (void)jumpHome;
- (void)enterChooseLang;
- (void)enterText;
- (void)enterVoice;
- (void)enterCamera;
- (void)enterUseful;
- (void)enterSubstitute;
- (void)enterBackgroud;
- (void)addReco:(NSString *)reco;

@end

NS_ASSUME_NONNULL_END
