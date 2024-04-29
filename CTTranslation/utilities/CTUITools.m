//
//  SVUITools.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/3/7.
//

#import "CTUITools.h"

@implementation CTUITools

@end

@implementation UIFont (CT)

+ (UIFont *)pFont:(CGFloat)size {
    return [self fontWithName:@"PingFangSC-Regular" size:size];
}

+ (UIFont *)fontWithSize:(CGFloat)size {
    return [UIFont fontWithSize:size weight:UIFontWeightRegular];
}

+ (UIFont *)fontWithSize:(CGFloat)size weight:(UIFontWeight)weight {
    NSString *name = @"PingFangSC-Regular";
    if (weight == UIFontWeightRegular) {
        //400
        name = @"PingFangSC-Regular";
    } else if (weight == UIFontWeightMedium) {
        //500
        name = @"PingFangSC-Medium";
    } else if (weight == UIFontWeightUltraLight) {
        //100
        name = @"PingFangSC-Ultralight";
    } else if (weight == UIFontWeightThin) {
        //200
        name = @"PingFangSC-Thin";
    } else if (weight == UIFontWeightLight) {
        //300
        name = @"PingFangSC-Light";
    } else if (weight == UIFontWeightSemibold) {
        //600
        name = @"PingFangSC-Semibold";
    } else if (weight == UIFontWeightBold) {
        //700
        name = @"PingFangSC-Bold";
    } else if (weight == UIFontWeightHeavy) {
        //800
        name = @"PingFangSC-Heavy";
    } else if (weight == UIFontWeightBlack) {
        //900
        name = @"PingFangSC-Black";
    }
    return [UIFont fontWithName:name size:size];
}

@end

@implementation UIColor (CT)

+ (UIColor *)hexColor:(NSString *)string {
    NSString *cString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if (cString.length < 6) {
        return [UIColor blackColor];
    }
    
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    if (cString.length != 6) {
        return [UIColor blackColor];
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
