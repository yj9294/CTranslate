//
//  CT.m
//  Co Translation
//
//  Created by  cttranslation on 2023/12/27.
//

#import "NSObject+CT.h"
#import "UIKit/UIKit.h"

@implementation NSObject (CT)

- (UIViewController *)getCurrentTopVC {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
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

@end
