//
//  CTTranslateManager.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/6.
//

#import <Foundation/Foundation.h>
#import "MLKitTranslate/MLKitTranslate.h"
#import <UIKit/UIImage.h>
#import "CTTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTTranslateManager : NSObject

+ (void)downloadWithLanguage:(MLKTranslateLanguage)language complete:(void(^)(BOOL isSuccess))complete;
+ (void)translateAsyncWithSource:(MLKTranslateLanguage)source target:(MLKTranslateLanguage)target text:(NSString *)text complete:(void(^)(NSString *result))complete;
+ (void)deleteWithLanguage:(MLKTranslateLanguage)language;
+ (BOOL)hasModelWithLanguage:(MLKTranslateLanguage)language;

+ (void)translateAndRecognizerWithImage:(UIImage *)image source:(CTTranslateModel *)source target:(CTTranslateModel *)target complete:(void(^)(NSString *recognizerText, NSString *result))complete;
@end

NS_ASSUME_NONNULL_END
