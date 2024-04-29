//
//  CTTranslateManager.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/6.
//

#import "CTTranslateManager.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitTextRecognition/MLKitTextRecognition.h>
#import <MLKitTextRecognitionChinese/MLKitTextRecognitionChinese.h>
#import <MLKitTextRecognitionKorean/MLKitTextRecognitionKorean.h>
#import <MLKitTextRecognitionJapanese/MLKitTextRecognitionJapanese.h>
#import <MLKitTextRecognitionDevanagari/MLKitTextRecognitionDevanagari.h>
#import <MLKitTextRecognitionCommon/MLKitTextRecognitionCommon.h>
#import <MLKitVision/MLKitVision.h>
#import <UIKit/UIOrientation.h>
#import <AVFoundation/AVCaptureDevice.h>

typedef NS_ENUM(NSUInteger, CTTranslateType) {
    CTTranslateTypeSuccess,
    CTTranslateTypeFailure,
    CTTranslateTypeNormal,
};

static CTTranslateType downloadType = CTTranslateTypeNormal;
static MLKTranslateRemoteModel *frenchModel = nil;

@implementation CTTranslateManager

+ (void)load {
    [NSNotificationCenter.defaultCenter
     addObserverForName:MLKModelDownloadDidSucceedNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
        if (note.userInfo == nil) return;
        MLKTranslateRemoteModel *model = note.userInfo[MLKModelDownloadUserInfoKeyRemoteModel];
        if ([model isKindOfClass:[MLKTranslateRemoteModel class]] && model == frenchModel) {
            frenchModel = nil;
            downloadType = CTTranslateTypeSuccess;
        }
     }];

    [NSNotificationCenter.defaultCenter
     addObserverForName:MLKModelDownloadDidFailNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
        if (note.userInfo == nil) return;
        NSError *error = note.userInfo[MLKModelDownloadUserInfoKeyError];
        NSLog(@"<Translate> download error:%@", error.localizedDescription);
        downloadType = CTTranslateTypeFailure;
     }];
}

+ (void)downloadWithLanguage:(MLKTranslateLanguage)language complete:(void(^)(BOOL isSuccess))complete {
    MLKTranslateRemoteModel *model = [MLKTranslateRemoteModel translateRemoteModelWithLanguage:language];
    if (![[MLKModelManager modelManager] isModelDownloaded:model]) {
        if (downloadType != CTTranslateTypeNormal) {
            if (complete) complete(NO);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            frenchModel = model;
            MLKModelDownloadConditions *conditions = [[MLKModelDownloadConditions alloc] initWithAllowsCellularAccess:YES allowsBackgroundDownloading:YES];
            [[MLKModelManager modelManager] downloadModel:model conditions:conditions];
            while (downloadType == CTTranslateTypeNormal) {
                sleep(0.5);
            }
            CTTranslateType type = downloadType;
            downloadType = CTTranslateTypeNormal;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (type == CTTranslateTypeSuccess) {
                    if (complete) complete(YES);
                } else {
                    if (complete) complete(NO);
                }
            });
        });
    } else {
        if (complete) complete(YES);
    }
}

+ (void)translateAsyncWithSource:(MLKTranslateLanguage)source target:(MLKTranslateLanguage)target text:(NSString *)text complete:(void(^)(NSString *result))complete {
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:source targetLanguage:target];
    MLKTranslator *translator = [MLKTranslator translatorWithOptions:options];
    [translator translateText:text completion:^(NSString * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (complete) complete(@"");
            NSLog(@"<Translate> translate error:%@", error.localizedDescription);
        } else {
            if (complete) complete(result);
        }
    }];
}

+ (void)deleteWithLanguage:(MLKTranslateLanguage)language {
    MLKTranslateRemoteModel *model =
        [MLKTranslateRemoteModel translateRemoteModelWithLanguage:language];
    [[MLKModelManager modelManager] deleteDownloadedModel:model completion:^(NSError * _Nullable error) {
        
    }];
}

+ (BOOL)hasModelWithLanguage:(MLKTranslateLanguage)language {
    MLKTranslateRemoteModel *model = [MLKTranslateRemoteModel translateRemoteModelWithLanguage:language];
    return [[MLKModelManager modelManager] isModelDownloaded:model];
}

+ (void)translateAndRecognizerWithImage:(UIImage *)image source:(CTTranslateModel *)source target:(CTTranslateModel *)target complete:(void(^)(NSString *recognizerText, NSString *result))complete {
    MLKTextRecognizer *recognizer = [self recognizerWithModel:source];
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    [recognizer processImage:visionImage completion:^(MLKText * _Nullable text, NSError * _Nullable error) {
        if (error) {
            NSLog(@"<Image Recognizer> error:%@", error.localizedDescription);
            if (complete) complete(@"", @"");
            return;
        }
        NSString *recognizerText = text.text;
        if (recognizerText.length == 0) {
            NSLog(@"<Image Recognizer> error: empty string");
            if (complete) complete(@"", @"");
        } else {
            //去翻译
            [self translateAsyncWithSource:source.language target:target.language text:recognizerText complete:^(NSString * _Nonnull result) {
                if (complete) complete(recognizerText, result);
            }];
        }
    }];
}

+ (MLKTextRecognizer *)recognizerWithModel:(CTTranslateModel *)model {
    MLKTextRecognizer *recognizer;
    if (model.recognizerFlag == CTRecognizerTypeLatn) {
        MLKTextRecognizerOptions *options = [[MLKTextRecognizerOptions alloc] init];
        recognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
    } else if (model.recognizerFlag == CTRecognizerTypeDeva) {
        MLKDevanagariTextRecognizerOptions *options = [[MLKDevanagariTextRecognizerOptions alloc] init];
        recognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
    } else if (model.recognizerFlag == CTRecognizerTypeHans) {
        MLKChineseTextRecognizerOptions *options = [[MLKChineseTextRecognizerOptions alloc] init];
        recognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
    } else if (model.recognizerFlag == CTRecognizerTypeJpan) {
        MLKJapaneseTextRecognizerOptions *options = [[MLKJapaneseTextRecognizerOptions alloc] init];
        recognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
    } else if (model.recognizerFlag == CTRecognizerTypeKore) {
        MLKKoreanTextRecognizerOptions *options = [[MLKKoreanTextRecognizerOptions alloc] init];
        recognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
    } else {
        MLKTextRecognizerOptions *options = [[MLKTextRecognizerOptions alloc] init];
        recognizer = [MLKTextRecognizer textRecognizerWithOptions:options];
    }
    return recognizer;
}

- (UIImageOrientation)imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
                         cameraPosition:(AVCaptureDevicePosition)cameraPosition {
  
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
        case UIDeviceOrientationLandscapeLeft:
            return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationDownMirrored : UIImageOrientationUp;
        case UIDeviceOrientationPortraitUpsideDown:
            return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationRightMirrored : UIImageOrientationLeft;
        case UIDeviceOrientationLandscapeRight:
            return cameraPosition == AVCaptureDevicePositionFront ? UIImageOrientationUpMirrored : UIImageOrientationDown;
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
      return UIImageOrientationUp;
  }
}

@end
