//
//  PDUITools.h
//  iOSDectionTk
//
//  Created by 孙浪 on 2022/4/25.
//  临时ui工具

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 状态栏高度
static inline CGFloat PDStatusHeight(void) {
    return ((UIWindowScene *)[[UIApplication sharedApplication].connectedScenes anyObject]).statusBarManager.statusBarFrame.size.height;
}

/// 屏幕宽度
static inline CGFloat PDScreenWidth(void) {
    return CGRectGetWidth(UIScreen.mainScreen.bounds);
}

/// 屏幕高度
static inline CGFloat PDScreenHeight(void) {
    return CGRectGetHeight(UIScreen.mainScreen.bounds);
}

static inline CGFloat PDSafeAreaBottom(void) {
    CGFloat bottom = 0;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        bottom = 0;
    }
     
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        if (window && window.windowLevel == UIWindowLevelNormal && CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds)) {
            bottom = window.safeAreaInsets.bottom;
            break;
        }
    }
    return bottom;
}

static inline CGRect PDAssistantMaxEdge(void) {
    return CGRectMake(5, PDStatusHeight(), PDScreenWidth() - 10, PDScreenHeight() - PDStatusHeight() - PDSafeAreaBottom());
}

@interface PDUITools : NSObject

+ (UIView *)showProgress:(NSString *)text;
+ (MBProgressHUD *)showProgress:(NSString *)text inView:(UIView *)inView;
+ (void)hideProgress:(UIView *)inView;
+ (void)showToast:(NSString *)text;
+ (UIWindow *)getRootWindow;
+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIViewController *)getCurrentTopVC;
+ (UIWindow *)getCurrentWindow;
+ (void)sendCUrlToChat:(NSString *)cUrl;
+ (void)sendLogToChat:(NSString *)log;
+ (void)sendLogsToChat:(NSArray *)logs complete:(nullable void(^)(BOOL isSuccess))complete;

@end

NS_ASSUME_NONNULL_END
