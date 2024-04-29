//
//  CTTranslateModel.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/6.
//

#import "CTTranslateModel.h"

@implementation CTTranslateModel

- (void)setType:(CTLanguageType)type {
    _type = type;
    self.name = [CTTranslateModel nameWithType:type];
    self.identifier = [CTTranslateModel identifierWithType:type];
    self.language = [CTTranslateModel languageWithType:type];
    self.recognizerFlag = [CTTranslateModel recognizerWithType:type];
}

+ (CTTranslateModel *)modelWithType:(CTLanguageType)type {
    CTTranslateModel *model = [[CTTranslateModel alloc] init];
    model.type = type;
    return model;
}

+ (NSString *)nameWithType:(CTLanguageType)type {
    NSUInteger index = type;
    NSArray *array = [self nameArray];
    if (array.count > index) {
        return array[index];
    } else {
        return array.firstObject;
    }
}

+ (NSString *)identifierWithType:(CTLanguageType)type {
    NSUInteger index = type;
    NSArray *array = [self identifierArray];
    if (array.count > index) {
        return array[index];
    } else {
        return array.firstObject;
    }
}

+ (MLKTranslateLanguage)languageWithType:(CTLanguageType)type {
    NSUInteger index = type;
    NSArray *array = [self languageArray];
    if (array.count > index) {
        return array[index];
    } else {
        return array.firstObject;
    }
}

+ (CTRecognizerType)recognizerWithType:(CTLanguageType)type {
    NSUInteger index = type;
    NSArray *array = [self recognizerArray];
    if (array.count > index) {
        return [array[index] integerValue];
    } else {
        return [array.firstObject integerValue];
    }
}

+ (NSArray <NSString *> *)nameArray {
    static NSArray *array = nil;
    if (array == nil) {
        array = @[@"English", @"French", @"German", @"Swedish", @"Hindi",
                  @"Spanish", @"Japanese", @"Arabic", @"Portuguese", @"Korean",
                  @"Vietnamese", @"Russian", @"Italian", @"Marathi", @"Urdu", 
                  @"Thai", @"Algerian\nArabic", @"Tunisian\nSpoken\nArabic", @"Gujarati", @"Telugu",
                  @"Tamil", @"Kannada",
                  @"Indonesian", @"Polish", @"Tagalog", @"Dutch",
                  @"Malay", @"Hungarian", @"Czech", @"Danish", @"Turkish", @"Greek",
                  @"Hebrew", @"Norwegian", @"Finnish", @"Irish", @"Croatian", 
                  @"Swahili", @"Belarusian", @"Chinese\nSimplified", @"Chinese\nTradition", @"Chinese\nCantonese",
                  @"Albanian", @"Afrikaans",
                  @"Bulgarian", @"Catalan", @"Estonian", @"Galician", @"Icelandic", 
                  @"Georgian", @"Lithuanian", @"Macedonian", @"Romanian", @"Slovenian"];
    }
    return array;
}

+ (NSArray <NSString *> *)identifierArray {
    static NSArray *array = nil;
    if (array == nil) {
        array = @[@"en_US", @"fr_FR", @"de_DE", @"sv_SE", @"hi_IN", 
                  @"es_ES", @"ja_JP", @"ar_SA", @"pt_PT", @"ko_KR",
                  @"vi_VN", @"ru_RU", @"it_IT", @"mr_IN", @"ur_Arab",
                  @"th_TH", @"ar_DZ", @"ar_TN", @"gu_IN", @"te_IN",
                  @"ta_IN", @"kn_IN",
                  @"id_ID", @"pl_PL", @"fil_PH", @"nl_NL", @"ms_MY",
                  @"hu_HU", @"cs_CZ", @"da_DK", @"tr_TR", @"el_GR",
                  @"he_IL", @"nb_NO", @"fi_FI", @"ga_IE", @"hr_HR", 
                  @"sw_KE", @"be_BY", @"zh_Hans_CN", @"zh_Hant_CN", @"yue_Hans_CN",
                  @"sq_AL", @"af_ZA",
                  @"bg_BG", @"ca_ES", @"et_EE", @"gl_ES", @"is_IS",
                  @"ka_GE", @"lt_LT", @"mk_MK", @"ro_RO", @"sl_SI"];
    }
    return array;
}

+ (NSArray <MLKTranslateLanguage> *)languageArray {
    static NSArray *array = nil;
    if (array == nil) {
        array = @[MLKTranslateLanguageEnglish,    MLKTranslateLanguageFrench,     MLKTranslateLanguageGerman,     MLKTranslateLanguageSwedish,    MLKTranslateLanguageHindi,
                  MLKTranslateLanguageSpanish,    MLKTranslateLanguageJapanese,   MLKTranslateLanguageArabic,     MLKTranslateLanguagePortuguese, MLKTranslateLanguageKorean,
                  MLKTranslateLanguageVietnamese, MLKTranslateLanguageRussian,    MLKTranslateLanguageItalian,    MLKTranslateLanguageMarathi,    MLKTranslateLanguageUrdu,
                  MLKTranslateLanguageThai,       MLKTranslateLanguageArabic,     MLKTranslateLanguageArabic,     MLKTranslateLanguageGujarati,   MLKTranslateLanguageTelugu,
                  MLKTranslateLanguageTamil,      MLKTranslateLanguageKannada,
                  MLKTranslateLanguageIndonesian, MLKTranslateLanguagePolish,     MLKTranslateLanguageTagalog,    MLKTranslateLanguageDutch,      MLKTranslateLanguageMalay,
                  MLKTranslateLanguageHungarian,  MLKTranslateLanguageCzech,      MLKTranslateLanguageDanish,     MLKTranslateLanguageTurkish,    MLKTranslateLanguageGreek,
                  MLKTranslateLanguageHebrew,     MLKTranslateLanguageNorwegian,  MLKTranslateLanguageFinnish,    MLKTranslateLanguageIrish,      MLKTranslateLanguageCroatian,
                  MLKTranslateLanguageSwahili,    MLKTranslateLanguageBelarusian, MLKTranslateLanguageChinese,    MLKTranslateLanguageChinese,    MLKTranslateLanguageChinese,
                  MLKTranslateLanguageAlbanian,   MLKTranslateLanguageAfrikaans,
                  MLKTranslateLanguageBulgarian,  MLKTranslateLanguageCatalan,    MLKTranslateLanguageEstonian,   MLKTranslateLanguageGalician,   MLKTranslateLanguageIcelandic,
                  MLKTranslateLanguageGeorgian,   MLKTranslateLanguageLithuanian, MLKTranslateLanguageMacedonian, MLKTranslateLanguageRomanian,   MLKTranslateLanguageSlovenian];
    }
    return array;
}

+ (NSArray *)recognizerArray {
    static NSArray *array = nil;
    if (array == nil) {
        array = @[@(0), @(0), @(0), @(0), @(1),
                  @(0), @(3), @(0), @(0), @(4),
                  @(0), @(0), @(0), @(1), @(0),
                  @(0), @(0), @(0), @(0), @(0),
                  @(0), @(0),
                  @(0), @(0), @(0), @(0), @(0),
                  @(0), @(0), @(0), @(0), @(0),
                  @(0), @(0), @(0), @(0), @(0),
                  @(0), @(0), @(2), @(2), @(2),
                  @(0), @(0),
                  @(0), @(0), @(0), @(0), @(0),
                  @(0), @(0), @(0), @(0), @(0)];
    }
    return array;
}

@end
