//
//  CTTranslateModel.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/6.
//

#import <Foundation/Foundation.h>
#import <MLKitTranslate/MLKitTranslate.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTLanguageType) {
    CTLanguageTypeEnglish = 0, //英语
    CTLanguageTypeFrench, //法语
    CTLanguageTypeGerman, //德语
    CTLanguageTypeSwedish, //瑞典语
    CTLanguageTypeHindi, //北印度语
    
    CTLanguageTypeSpanish, //西班牙语
    CTLanguageTypeJapanese, //日语
    CTLanguageTypeArabic, //阿拉伯语
    CTLanguageTypePortuguese, //葡萄牙语
    CTLanguageTypeKorean, //韩语
    
    CTLanguageTypeVietnamese, //越南语
    CTLanguageTypeRussian, //俄语
    CTLanguageTypeItalian, //意大利语
    CTLanguageTypeMarathi, //马拉地语
    CTLanguageTypeUrdu, //乌尔都语
    
    CTLanguageTypeThai, //泰国语
    CTLanguageTypeAlgerianArabic, //
    CTLanguageTypeTunisianSpokenArabic, //
    CTLanguageTypeGujarati, //古吉特语
    CTLanguageTypeTelugu, //泰卢固语
    
    CTLanguageTypeTamil, //泰米尔语
    CTLanguageTypeKannada, //卡纳达语
    
    CTLanguageTypeIndonesian, //印度尼西亚语
    CTLanguageTypePolish, //波兰语
    CTLanguageTypeTagalog, //塔加路语
    CTLanguageTypeDutch, //荷兰语
    CTLanguageTypeMalay, //马来语
    
    CTLanguageTypeHungarian, //匈牙利语
    CTLanguageTypeCzech, //捷克语
    CTLanguageTypeDanish, //丹麦语
    CTLanguageTypeTurkish, //土耳其语
    CTLanguageTypeGreek, //希腊语
    
    CTLanguageTypeHebrew, //希伯来语
    CTLanguageTypeNorwegian, //挪威语
    CTLanguageTypeFinnish, //芬兰语
    CTLanguageTypeIrish, //爱尔兰语
    CTLanguageTypeCroatian, //克罗地亚语
    
    CTLanguageTypeSwahili, //斯瓦希里语
    CTLanguageTypeBelarusian, //白俄罗斯语
    CTLanguageTypeChineseSimplified, //中文
    CTLanguageTypeChineseTradition,
    CTLanguageTypeChineseCantonese,
    
    CTLanguageTypeAlbanian, //阿尔巴尼亚语
    CTLanguageTypeAfrikaans, //南非荷兰语
    
    CTLanguageTypeBulgarian, //保加利亚语
    CTLanguageTypeCatalan, //加泰罗尼亚语
    CTLanguageTypeEstonian, //爱沙尼亚语
    CTLanguageTypeGalician, //加利西亚语
    CTLanguageTypeIcelandic, //冰岛语
    
    CTLanguageTypeGeorgian, //格鲁吉亚语
    CTLanguageTypeLithuanian, //立陶宛语
    CTLanguageTypeMacedonian, //马其顿语
    CTLanguageTypeRomanian, //罗马尼亚语
    CTLanguageTypeSlovenian, //斯洛文尼亚语
};


typedef NS_ENUM(NSUInteger, CTRecognizerType) {
    CTRecognizerTypeLatn = 0, //拉丁文
    CTRecognizerTypeDeva, //梵文
    CTRecognizerTypeHans, //中文
    CTRecognizerTypeJpan, //日文
    CTRecognizerTypeKore, //韩文
};
@interface CTTranslateModel : NSObject

@property (nonatomic, copy) MLKTranslateLanguage language;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CTRecognizerType recognizerFlag;
@property (nonatomic, assign) CTLanguageType type;
//是否已下载
@property (nonatomic, assign) BOOL isDownload;

+ (CTTranslateModel *)modelWithType:(CTLanguageType)type;
+ (NSArray <MLKTranslateLanguage> *)languageArray;
+ (NSArray *)nameArray;


@end

NS_ASSUME_NONNULL_END
