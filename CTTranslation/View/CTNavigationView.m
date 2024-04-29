//
//  CTNavigationView.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/27.
//

#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"

@implementation CTNavigationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = CGRectMake(0, CTStatusHeight(), CTScreenWidth(), 44);
    
    self.textLabel = [UILabel lbText:@"" font:[UIFont fontWithSize:17 weight:UIFontWeightMedium] color:[UIColor whiteColor]];
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
    }];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton nImage:[UIImage imageNamed:@"back"] hImage:nil];
    [self.leftButton setEnlargeEdge:10];
    [self.leftButton addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.width.mas_equalTo(22);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)navBack {
    if (self.viewController.navigationController.viewControllers.count <= 1) {
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
}

@end
