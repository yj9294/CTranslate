//
//  SVUITools.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/3/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTUITools : NSObject

@end

@interface UIFont (CT)

+ (UIFont *)pFont:(CGFloat)size;
+ (UIFont *)fontWithSize:(CGFloat)size;
+ (UIFont *)fontWithSize:(CGFloat)size weight:(UIFontWeight)weight;

@end

@interface UIColor (CT)

+ (UIColor *)hexColor:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
