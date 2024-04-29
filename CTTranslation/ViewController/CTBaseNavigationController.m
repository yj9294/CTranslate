//
//  CTBaseNavigationController.m
//  Co Translation
//
//  Created by  cttranslation on 2023/12/25.
//

#import "CTBaseNavigationController.h"

@interface CTBaseNavigationController ()

@end

@implementation CTBaseNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count == 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    } else {
        viewController.hidesBottomBarWhenPushed = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    if (self.viewControllers.count > 1) {
        UIViewController *viewController = [self.viewControllers lastObject];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super setViewControllers:viewControllers animated:animated];
}


@end
