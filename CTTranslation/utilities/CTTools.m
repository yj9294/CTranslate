//
//  CTTools.m
//  Co Translation
//
//  Created by  cttranslation on 2024/2/21.
//

#import "CTTools.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <Photos/PHPhotoLibrary.h>
#import <Speech/SFSpeechRecognizer.h>
@implementation CTTools

+ (NSString *)ct_getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)ct_getAppName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)randomStringWithLengh:(int)len {
    char ch[len];
    for (int index = 0; index < len; index++) {
        int num = arc4random_uniform(75) + 48;
        if (num > 57 && num < 65) {
            num = num % 57 + 48;
        } else if (num > 90 && num < 97) {
            num = num % 90 + 65;
        }
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

+ (BOOL)isLimitCountry {
    NSLocale *locale = [NSLocale currentLocale];
    if (@available(iOS 17.0, *)) {
        NSString *code = [locale regionCode];
        if ([code isEqualToString:@"CN"]) {
            return YES;
        }
    } else {
        NSString *code = [locale objectForKey:NSLocaleCountryCode];
        if ([code containsString:@"CN"]) {
            return YES;
        }
    }
    return NO;
}

+ (void)cameraAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if (complete) complete(YES, nil);
                } else {
                    if (complete) complete(NO, nil);
                }
            });
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        if (complete) complete(YES, nil);
    } else {
        NSString *appName = [self ct_getAppName];
        NSString *message = [NSString stringWithFormat:@"[Please open camera permissions, Go to:Setting-Privacy-Camera-%@]", appName];
        if (complete) complete(NO, message);
    }
}

+ (void)speechAndMicrophoneWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete {
    [self microphoneAuthWithComplete:^(BOOL isSuccess, NSString * _Nullable message) {
        if (!isSuccess) {
            if (complete) complete(isSuccess, message);
            return;
        }
        [self speechAuthWithComplete:complete];
    }];
}

+ (void)microphoneAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if (complete) complete(YES, nil);
                } else {
                    if (complete) complete(NO, nil);
                }
            });
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        if (complete) complete(YES, nil);
    } else {
        NSString *appName = [self ct_getAppName];
        NSString *message = [NSString stringWithFormat:@"[Please open microphone permissions, Go to:Setting-Privacy-Microphone-%@]", appName];
        if (complete) complete(NO, message);
    }
}

+ (void)speechAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete {
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                    if (complete) complete(YES, nil);
                } else {
                    if (complete) complete(NO, nil);
                }
            });
        }];
    } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        if (complete) complete(YES, nil);
    } else {
        NSString *appName = [self ct_getAppName];
        NSString *message = [NSString stringWithFormat:@"[Please open speech recognition permissions, Go to:Setting-Privacy-Speech Recognition-%@]", appName];
        if (complete) complete(NO, message);
    }
}

+ (void)albumAuthWithComplete:(void(^)(BOOL isSuccess, NSString * _Nullable message))complete {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    if (complete) complete(YES, nil);
                } else {
                    if (complete) complete(NO, nil);
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        if (complete) complete(YES, nil);
    } else {
        NSString *appName = [self ct_getAppName];
        NSString *message = [NSString stringWithFormat:@"[Please open photo permissions, Go to:Setting-Privacy-Photo-%@]", appName];
        if (complete) complete(NO, message);
    }
}

@end
