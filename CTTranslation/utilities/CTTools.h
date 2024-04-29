//
//  CTTools.h
//  Co Translation
//
//  Created by  cttranslation on 2024/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTTools : NSObject

+ (NSString *)ct_getAppVersion;
+ (NSString *)ct_getAppName;
+ (NSString *)randomStringWithLengh:(int)len;
+ (BOOL)isLimitCountry;
+ (void)cameraAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete;
+ (void)speechAndMicrophoneWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete;
+ (void)microphoneAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete;
+ (void)speechAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete;
+ (void)albumAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete;
@end

NS_ASSUME_NONNULL_END
