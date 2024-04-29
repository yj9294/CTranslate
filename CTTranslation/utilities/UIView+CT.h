//
//  SV.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/25.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "CTUITools.h"

NS_ASSUME_NONNULL_BEGIN

static inline CGFloat CTBottom(void) {
    return ((UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject]).windows.firstObject.safeAreaInsets.bottom > 0 ? 25 : 10;
}

static inline CGFloat CTTabHeight(void) {
    return 49;
}

static inline CGFloat CTScreenWidth(void) {
    return CGRectGetWidth(UIScreen.mainScreen.bounds);
}

static inline CGFloat CTSafeAreaBottom(void) {
    return ((UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject]).windows.firstObject.safeAreaInsets.bottom;
}

static inline CGFloat CTScreenHeight(void) {
    return CGRectGetHeight(UIScreen.mainScreen.bounds);
}

static inline CGFloat CTScreenScale(void) {
    return UIScreen.mainScreen.scale;
}


static inline CGFloat CTStatusHeight(void) {
    return ((UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject]).statusBarManager.statusBarFrame.size.height;;
}

static inline CGFloat CTNavHeight(void) {
    return 44 + CTStatusHeight();
}

@interface UIView (CT)

- (UIViewController *)viewController;
- (UINavigationController *)navController;

@end

@interface UIView (Tip)

+ (UIView *)ct_showLoading:(NSString *)text;
+ (void)ct_hideLoading;
+ (void)ct_hideLoading:(UIView *)inView;
+ (void)ct_tipToast:(nullable NSString *)text;
+ (void)ct_tipForeplayWithComplete:(void(^)(void))complete;

@end

@interface UIImage (CT)

+ (UIImage *)ct_imageWithColor:(UIColor *)color;
//+ (UIImage *)generateQrcodeImageWithStr:(NSString *)QcodeStr size:(float)size;
+ (UIImage *)ct_deepImageWithColor:(UIColor *)color;
- (UIImage *)ct_imageWithAlpha:(CGFloat)alpha;
- (UIImage *)ct_adjustImageColorByFactor:(CGFloat)factor;

@end

@interface UIButton (CT)
+ (UIButton *)btTitle:(NSString *)title;

- (void)bgColor:(UIColor *)color;
- (void)bgImage:(UIImage *)image;

- (void)tColor:(UIColor *)color;
- (void)nImage:(UIImage *)image hImage:(UIImage * _Nullable)sImage;

@end

@interface  UILabel (CT)

//- (void)adjustSize;
+ (UILabel *)lbText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;

@end



NS_ASSUME_NONNULL_END
