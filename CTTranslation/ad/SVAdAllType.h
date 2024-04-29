//
//  SVAdAllType.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/3/7.
//

#ifndef SVAdAllType_h
#define SVAdAllType_h

typedef NS_ENUM(NSUInteger, CTAdvertLocationType) {
    CTAdvertLocationTypeLaunch = 0, //启动插屏
    CTAdvertLocationTypeSelectLang,
    CTAdvertLocationTypeClick,
    CTAdvertLocationTypeBack,
    CTAdvertLocationTypeTranslate,
    CTAdvertLocationTypeUseful,
    CTAdvertLocationTypeSubstitute,
    CTAdvertLocationTypeSelectLangNative,
    CTAdvertLocationTypeTranslateNative,
    CTAdvertLocationTypeSetNative,
    CTAdvertLocationTypeTranslateBanner,
    CTAdvertLocationTypeUnknow,
};

typedef NS_ENUM(NSUInteger, CTAdvertType) {
    CTAdvertTypeInterstitial = 0,
    CTAdvertTypeOpen,
    CTAdvertTypeNative,
//    CTAdvertTypeBanner,
};

#endif /* SVAdAllType_h */
