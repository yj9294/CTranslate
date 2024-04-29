//
//  CTPosterModel.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import "CTPosterModel.h"

@implementation CTPosterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ild = NO;
        self.isw = NO;
        self.tld = 0;
        self.tsw = 0;
        self.tsld = 0;
        self.tut = 0;
        self.msw = 20;
        self.mck = 10;
        self.cck = 0;
        self.csw = 0;
    }
    return self;
}

- (void)setName:(NSString *)name {
    CTAdvertLocationType type = CTAdvertLocationTypeUnknow;
    if ([name isEqualToString:@"launch"]) {
        type = CTAdvertLocationTypeLaunch;
    } else if ([name isEqualToString:@"selectLang"]) {
        type = CTAdvertLocationTypeSelectLang;
    } else if ([name isEqualToString:@"click"]) {
        type = CTAdvertLocationTypeClick;
    } else if ([name isEqualToString:@"back"]) {
        type = CTAdvertLocationTypeBack;
    } else if ([name isEqualToString:@"translate"]) {
        type = CTAdvertLocationTypeTranslate;
    } else if ([name isEqualToString:@"useful"]) {
        type = CTAdvertLocationTypeUseful;
    } else if ([name isEqualToString:@"substitute"]) {
        type = CTAdvertLocationTypeSubstitute;
    } else if ([name isEqualToString:@"selectLangNative"]) {
        type = CTAdvertLocationTypeSelectLangNative;
    } else if ([name isEqualToString:@"translateNative"]) {
        type = CTAdvertLocationTypeTranslateNative;
    } else if ([name isEqualToString:@"setNative"]) {
        type = CTAdvertLocationTypeSetNative;
    } else if ([name isEqualToString:@"translateBanner"]) {
        type = CTAdvertLocationTypeTranslateBanner;
    }
    self.posty = type;
    _name = name;
}

- (NSUInteger)hash {
    return  self.name.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    CTPosterModel *model = (CTPosterModel *)object;
    return [self.name isEqualToString:model.name];
}

@end
