//
//  CTHistoryModel.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTHistoryModel : NSObject

@property (nonatomic, strong) NSString *sourceLang;
@property (nonatomic, strong) NSString *sourceText;
@property (nonatomic, strong) NSString *targetLang;
@property (nonatomic, strong) NSString *targetText;

@property (nonatomic, strong) NSString *historyId;
@property (nonatomic, assign) NSUInteger sourceType;
@property (nonatomic, assign) NSUInteger targetType;

@property (nonatomic, assign) BOOL isShowBox;
@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
