//
//  CTMainViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTMainViewController.h"
#import "UIView+CT.h"
#import "CTBaseNavigationController.h"
#import "CTHomeViewController.h"
#import "CTSettingViewController.h"

@interface CTMainViewController () <UITabBarControllerDelegate>

@end

@implementation CTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self setupAppearance];
    [self setupVC];
}

- (void)setupAppearance {
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor hexColor:@"#999999"], NSFontAttributeName: [UIFont pFont:10]};
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor hexColor:@"#D56F5E"], NSFontAttributeName: [UIFont pFont:10]};
    appearance.backgroundColor = [UIColor hexColor:@"#192D41"];
    self.tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance;
    }
}

- (void)setupVC {
    [self setupChildVC:[[CTHomeViewController alloc] init] image:[UIImage imageNamed:@"tabbar_home_normal"] selectImage:[UIImage imageNamed:@"tabbar_home_select"] title:@"Home"];
    [self setupChildVC:[[CTSettingViewController alloc] init] image:[UIImage imageNamed:@"tabbar_set_normal"] selectImage:[UIImage imageNamed:@"tabbar_set_select"] title:@"Settings"];
}

- (void)setupChildVC:(UIViewController *)vc image:(UIImage *)image selectImage:(UIImage *)selectImage title:(NSString *)title {
    vc.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    vc.title = title;
    vc.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    CTBaseNavigationController *navigationController = [[CTBaseNavigationController alloc] initWithRootViewController:vc];
    navigationController.navigationBar.hidden = YES;
    [self addChildViewController:navigationController];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:CTBaseNavigationController.class]) {
        UIViewController *root = [(CTBaseNavigationController *)viewController viewControllers].firstObject;
        if ([root isKindOfClass:CTSettingViewController.class]) {
            [GADUtil.shared disappear:GADPositionNative];
            [GADUtil.shared load:GADPositionNative p:GADSceneSettingsNative completion:nil];
        } else {
            [GADUtil.shared disappear:GADPositionNative];
        }
    }
    
    return true;
}
@end
