//
//  CTFbHandle.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/29.
//

#import <Foundation/Foundation.h>
#import <FirebaseRemoteConfig/FirebaseRemoteConfig.h>
NS_ASSUME_NONNULL_BEGIN

#define CTFirebase [CTFbHandle shared]

@interface CTFbHandle : NSObject

@property (nonatomic, strong, readonly) FIRRemoteConfig *remoteInfo;

+ (CTFbHandle *)shared;
- (void)configreRemoteInfo;
- (void)configureAdvert;
- (void)appInfoWithComplete:(void(^)(BOOL isSuccess, id config))complete;
- (NSArray *)getRecommendList;
- (NSString *)getAppMode;
- (NSInteger)getGuid;

@end

NS_ASSUME_NONNULL_END
