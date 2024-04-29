//
//  CTLaunchViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2023/12/28.
//

#import "CTLaunchViewController.h"
#import "Masonry/Masonry.h"
//#import "CTTranslation-Swift.h"
#import "UIView+CT.h"

@implementation CTLaunchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_logo"]];
        [self addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(110);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(117);
            make.height.mas_equalTo(87);
        }];
        
        UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_title"]];
        [self addSubview:titleImageView];
        [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(217);
            make.width.mas_equalTo(170);
            make.height.mas_equalTo(18);
            make.centerX.mas_equalTo(0);
        }];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_bg"]];
        bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(387);
            make.height.mas_equalTo(295);
            make.centerX.mas_equalTo(0);
        }];
        
        [self addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-30);
            make.width.mas_equalTo(235);
            make.height.mas_equalTo(8);
            make.centerX.mas_equalTo(0);
        }];
        
        [self progressManager];
    }
    return self;
}

- (void)progressManager {
    __weak typeof(self) weakSelf = self;
    [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.progressView.progress > 1) {
            [timer invalidate];
        } else {
            weakSelf.progressView.progress += 0.0015;
        }
    }];
}

- (void)stop {
    [self.progressView setProgress:1.0 animated:YES];
    self.progressView.hidden = YES;
}

- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.tintColor = [UIColor hexColor:@"#D9D9D9"];
        _progressView.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _progressView.layer.cornerRadius = 4;
        _progressView.layer.masksToBounds = YES;
    }
    return _progressView;
}

@end

@interface CTLaunchViewController ()
@end

@implementation CTLaunchViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTLaunchView *launchView = [[CTLaunchView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:launchView];
}

@end
