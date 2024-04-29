//
//  PDUITools.m
//  iOSDectionTk
//
//  Created by 孙浪 on 2022/4/25.
//

#import "PDUITools.h"
#include <objc/runtime.h>

//飞书
static NSString *const kWebhook = @"https://open.feishu.cn/open-apis/bot/v2/hook/7a2d3951-2d49-4be9-b6fc-8b0d81b0b21b";

@implementation PDUITools

+ (UIView *)showProgress:(NSString *)text {
    UIWindow *window = [self getRootWindow];
    [self showProgress:text inView:window];
    return window;
}

+ (MBProgressHUD *)showProgress:(NSString *)text inView:(UIView *)inView {
    [self hideProgress:inView];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    [hud.label setText:text.length > 0 ? text : @"加载中"];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setMinSize:CGSizeMake(150, 75)];

    [hud.label setNumberOfLines:0];
    [hud.label setFont:[UIFont systemFontOfSize:16]];
    [hud.label setTextColor:[UIColor whiteColor]];
    
    UIColor *bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    [hud.bezelView setColor:bgColor];
    [hud.bezelView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    return hud;
}

+ (void)hideProgress:(UIView *)inView {
    [MBProgressHUD hideHUDForView:inView animated:YES];
}

+ (void)showToast:(NSString *)text {
    UIWindow *window = [self getRootWindow];
    MBProgressHUD *hud = [self showProgress:text inView:window];
    [hud hideAnimated:YES afterDelay:1];
}

+ (UIWindow *)getRootWindow {
    NSArray *scenes = [[[UIApplication sharedApplication] connectedScenes] allObjects];
    UIWindowScene *scene = [scenes firstObject];
    UIWindow *window = [scene valueForKeyPath:@"delegate.window"];
    if ([self isScreenWindow:window]) {
        return window;
    } else {
        return [self getWindowForScene];
    }
}

+ (UIWindow *)getWindowForScene {
    NSArray *scenes = [[[UIApplication sharedApplication] connectedScenes] allObjects];
    UIWindow *window;
    for (UIWindowScene *scene in scenes) {
        for (UIWindow *win in scene.windows) {
            if ([self isScreenWindow:win]) {
                window = win;
                break;
            }
        }
        if (window) break;
    }
    if (window) return window;
    
    NSArray *windows = UIApplication.sharedApplication.windows;
    for (UIWindow *win in windows) {
        if ([self isScreenWindow:win]) {
            window = win;
            break;
        }
    }
    if (window) return window;
    return UIApplication.sharedApplication.windows.firstObject;
}

+ (BOOL)isScreenWindow:(UIWindow *)window {
    if (window && window.windowLevel == UIWindowLevelNormal && CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds)) {
        return YES;
    }
    return NO;
}

+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow *window = [self getCurrentWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;

    return result;
}

/// 获取当前屏幕显示的Controller，直接返回当前控制器的名称
/// 用于页面Loading
+ (UIViewController *)getCurrentTopVC {
//    UIWindow *delegateWindow = [UIApplication.sharedApplication valueForKeyPath:@"delegate.window"];
    UIWindow *window = [self getCurrentWindow];
//    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

+ (UIWindow *)getCurrentWindow {
    NSArray *windows = [[[UIApplication sharedApplication].windows reverseObjectEnumerator] allObjects];
    for (UIWindow *window in windows) {
        BOOL windowOnMainScreen = (window.screen == UIScreen.mainScreen);
        BOOL isWindowVisible = (!window.isHidden && window.alpha > 0);
        BOOL windowLevelSupport = (window.windowLevel == UIWindowLevelNormal);
        BOOL isKeyWindow;
        if (@available(iOS 14.0, *)) {
            isKeyWindow = YES;
        } else {
            //在iOS14以上，点击新创建window会更新成keywindow;
            isKeyWindow = window.isKeyWindow;
        }
        
        if (windowOnMainScreen && isWindowVisible && windowLevelSupport && isKeyWindow) {
            return window;
        }
    }
    
    return [self getRootWindow];
}


+ (void)sendCUrlToChat:(NSString *)cUrl {
    NSString *title = @"【APP Words】iOS cURL自动上发";
    [self sendToChatWithTitle:title content:cUrl complete:nil];
}

+ (void)sendLogToChat:(NSString *)log {
    NSString *title = @"【APP Words】iOS 日志 自动上发";
    [self sendToChatWithTitle:title content:log complete:nil];
}

+ (void)sendLogsToChat:(NSArray *)logs complete:(void(^)(BOOL isSuccess))complete {
    NSArray *newLogs = [[logs reverseObjectEnumerator] allObjects];
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < newLogs.count; i++) {
        [string appendFormat:@"%@\n\n", newLogs[i]];
    }
    NSString *title = @"*****************↓↓↓↓↓↓↓↓【APP Words】iOS 全量日志 自动上发 ↓↓↓↓↓↓↓↓*****************";
    [self sendToChatWithTitle:title content:string complete:complete];
}

+ (void)sendToChatWithTitle:(NSString *)title content:(NSString *)content complete:(nullable void(^)(BOOL isSuccess))complete {
    NSUInteger stringLengthInBytes = [content lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger chunkSize = 20 * 1024;
    if (stringLengthInBytes > chunkSize) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block BOOL result = YES;
            __block NSString *reMsg;
            NSUInteger numberOfChunks = (stringLengthInBytes + chunkSize - 1) / chunkSize;
            dispatch_semaphore_t semapore = dispatch_semaphore_create(0);
            for (NSUInteger i = 0; i < numberOfChunks; i++) {
                NSRange range = NSMakeRange(i * chunkSize, MIN(chunkSize, stringLengthInBytes - i * chunkSize));
                NSString *chunkString = [content substringWithRange:range];
                
                NSString *markdown;
                if (i == 0) {
//                    markdown = [NSString stringWithFormat:@"%@ <at user_id=\"all\">所有人</at>\n\n%@", title, chunkString];
                    markdown = [NSString stringWithFormat:@"%@ \n\n%@", title, chunkString];
                } else {
                    markdown = [NSString stringWithFormat:@"接上一条消息\n\n%@", chunkString];
                }
                NSMutableDictionary *params = [NSMutableDictionary new];
                [params setValue:@"text" forKey:@"msg_type"];
                [params setValue:@{@"text" : markdown} forKey:@"content"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
                
                NSURL *url = [NSURL URLWithString:kWebhook];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:jsonData];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error) {
                        result = NO;
                        reMsg = [reMsg stringByAppendingFormat:@"\n%@", error.userInfo[NSLocalizedDescriptionKey]];
                        dispatch_semaphore_signal(semapore);
                        return;
                    }
                    
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    NSString *msg = [dic objectForKey:@"msg"];
                    if ([msg isEqualToString:@"success"]) {
                    } else {
                        result = NO;
                        reMsg = [reMsg stringByAppendingFormat:@"\n%@", msg];
                    }
                    dispatch_semaphore_signal(semapore);
                }] resume];
                dispatch_semaphore_wait(semapore, DISPATCH_TIME_FOREVER);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    [PDUITools showToast:@"发送成功"];
                } else {
                    [PDUITools showToast:reMsg];
                }
                if (complete) complete(result);
            });
        });
        
    } else {
//        NSString *markdown = [NSString stringWithFormat:@"%@ <at user_id=\"all\">所有人</at>\n\n%@", title, content];
        NSString *markdown = [NSString stringWithFormat:@"%@ \n\n%@", title, content];
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"text" forKey:@"msg_type"];
        [params setValue:@{@"text" : markdown} forKey:@"content"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        
        NSURL *url = [NSURL URLWithString:kWebhook];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [PDUITools showToast:error.userInfo[NSLocalizedDescriptionKey]];
                    if (complete) complete(NO);
                    return;
                }
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSString *msg = [result objectForKey:@"msg"];
                if ([msg isEqualToString:@"success"]) {
                    [PDUITools showToast:@"发送成功"];
                    if (complete) complete(YES);
                } else {
                    if (complete) complete(NO);
                    [PDUITools showToast:msg];
                }
            });
        }] resume];
    }
}

@end
