//
//  CTBaseViewController.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/1.
//

#import "CTBaseViewController.h"
#import "CTPosterManager.h"


typedef NS_ENUM(NSUInteger, CTViewControllerStatus) {
    CTViewControllerStatusWillAppear = 0,
    CTViewControllerStatusDidAppear,
    CTViewControllerStatusWillDisappear,
    CTViewControllerStatusDidDisappear
};

@interface CTBaseViewController () {
    CTViewControllerStatus __vcStatus;
}
@end

@implementation CTBaseViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __vcStatus = CTViewControllerStatusWillAppear;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.vcIsDid) {
        self.vcIsDid = YES;
        if (self.vcIsShowAding) {
            self.vcIsShowAding = NO;
        } else {
            [self didVC];
        }
    }
    __vcStatus = CTViewControllerStatusDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (__vcStatus == CTViewControllerStatusWillAppear && self.vcIsShowAding) {
        self.vcIsShowAding = NO;
    }
    __vcStatus = CTViewControllerStatusWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.vcIsDid) {
        self.vcIsDid = NO;
        __vcStatus = CTViewControllerStatusDidDisappear;
    } else {
        __vcStatus = CTViewControllerStatusDidDisappear;
    }
}

- (void)didVC {
    [[CTPosterManager sharedInstance] enterSubstitute];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupUI];
}

- (void)__setupUI {
    self.vcIsDid = NO;
    self.vcIsShowAding = NO;
}

@end
