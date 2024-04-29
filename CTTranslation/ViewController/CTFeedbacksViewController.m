//
//  CTFeedbacksViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import "CTFeedbacksViewController.h"
#import "CTNavigationView.h"
#import "CTTextView.h"
#import "UIView+CT.h"
#import "CTPosterManager.h"

@interface CTFeedbacksViewController ()

@property (nonatomic, strong) CTTextView *textView;

@end

@implementation CTFeedbacksViewController

- (void)didVC {
    [super didVC];
    [[CTPosterManager sharedInstance] addReco:@"feed"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    nav.textLabel.text = @"Feedbacks";
    [self.view addSubview:nav];
    
    UILabel *label = [UILabel lbText:@"Please leave your valuable comments" font:[UIFont pFont:16] color:[UIColor whiteColor]];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
    }];
    
    CTTextView *textView = [[CTTextView alloc] init];
    textView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
    textView.layer.cornerRadius = 15;
    textView.layer.masksToBounds = YES;
    [textView configPlaceholder:@"Please enter..." font:[UIFont pFont:16] textColor:[UIColor colorWithWhite:1 alpha:0.6]];
    textView.textContainerInset = UIEdgeInsetsMake(15, 15, 15, 15);
    [self.view addSubview:textView];
    self.textView = textView;
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    UIButton *button = [UIButton btTitle:@"Send"];
    [button addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(274);
        make.height.mas_equalTo(46);
        make.bottom.mas_equalTo(-CTSafeAreaBottom()-40);
    }];
}

- (void)okAction {
    if (self.textView.text.length == 0) {
        [UIView ct_tipToast:@"No Content!"];
        return;
    }
    [UIView ct_showLoading:@"Sending..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView ct_hideLoading];
        [UIView ct_tipToast:@"Send successful!"];
        [self.navigationController popViewControllerAnimated:YES];
    });
}


@end
