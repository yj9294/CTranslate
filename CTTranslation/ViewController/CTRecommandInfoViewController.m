//
//  CTRecommandInfoViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import "CTRecommandInfoViewController.h"
#import "CTTranslateViewController.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"
#import <Speech/Speech.h>

@interface CTRecommandInfoViewController () <AVSpeechSynthesizerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation CTRecommandInfoViewController

- (void)didVC {
    [super didVC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.synthesizer isSpeaking]) {
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    nav.textLabel.text = @"Today's Recommend";
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nav];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton nImage:[UIImage imageNamed:@"recommed_translate"] hImage:nil];
    [rightButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.width.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor hexColor:@"#D9D9D9"];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(35);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-CTSafeAreaBottom()-75);
    }];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = scrollView.backgroundColor;
    [scrollView addSubview:bgView];
    self.bgView = bgView;
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.width.equalTo(scrollView);
        make.height.greaterThanOrEqualTo(scrollView);
    }];
    
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceButton bgImage:[UIImage imageNamed:@"recommed_voice"]];
    [voiceButton setEnlargeEdge:15];
    [voiceButton addTarget:self action:@selector(voiceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceButton];
    [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scrollView.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.width.height.mas_offset(30);
    }];
    
    [self configureUI];
}

- (void)configureUI {
    NSUInteger imageNumber = arc4random_uniform(12) + 1;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"recommed_bg%lu", (unsigned long)imageNumber]]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.bgView addSubview:imageView];
    
    UILabel *contentLabel = [UILabel lbText:self.translateText font:[UIFont fontWithSize:16 weight:UIFontWeightLight] color:[UIColor hexColor:@"#333333"]];
    contentLabel.numberOfLines = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineHeightMultiple = 2;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.translateText attributes:@{NSFontAttributeName: [UIFont fontWithSize:16 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor hexColor:@"#333333"], NSParagraphStyleAttributeName: paragraphStyle}];
    contentLabel.preferredMaxLayoutWidth = 210;
    contentLabel.attributedText = attributeString;
    [self.bgView addSubview:contentLabel];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM d";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    UILabel *timeLabel = [UILabel lbText:time font:[UIFont fontWithSize:17 weight:UIFontWeightMedium] color:[UIColor hexColor:@"#333333"]];
    [self.bgView addSubview:timeLabel];
    
    UIImageView *maskImageView = [[UIImageView alloc] init];
    maskImageView.contentMode = UIViewContentModeScaleAspectFill;
    maskImageView.clipsToBounds = YES;
    [imageView addSubview:maskImageView];
    
    NSUInteger maskNumber = arc4random_uniform(4) + 1;
    if (maskNumber == 1) {
        UIImageView *barImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommed_bar_right"]];
        maskImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"recommed_mask%lu", (unsigned long)maskNumber]];
        [self.bgView addSubview:barImageView];
        [barImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50);
            make.right.mas_equalTo(0);
            make.width.mas_equalTo(321);
            make.height.mas_equalTo(5);
        }];
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(barImageView.mas_bottom).offset(10);
            make.right.mas_equalTo(-10);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLabel.mas_bottom);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(236);
        }];
        
        [maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(0);
        }];
        
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(30);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(210);
            make.bottom.mas_lessThanOrEqualTo(-20);
        }];
        
    } else if (maskNumber == 2) {
        UIImageView *barImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommed_bar_left"]];
        maskImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"recommed_mask%lu", (unsigned long)maskNumber]];
        [self.bgView addSubview:barImageView];
        [barImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(321);
            make.height.mas_equalTo(5);
        }];
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(barImageView.mas_bottom).offset(10);
            make.left.mas_equalTo(10);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(252);
        }];
        
        [maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(0);
        }];
        
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(18);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(210);
            make.bottom.mas_lessThanOrEqualTo(-20);
        }];
    } else if (maskNumber == 3) {
        UIImageView *barImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommed_bar_left"]];
        maskImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"recommed_mask%lu", (unsigned long)maskNumber]];
        [self.bgView addSubview:barImageView];
        [barImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(321);
            make.height.mas_equalTo(5);
        }];
        
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(barImageView.mas_bottom).offset(23);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(210);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentLabel.mas_bottom).offset(30);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(252);
            make.bottom.mas_lessThanOrEqualTo(-20);
        }];
        
        [maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(0);
        }];
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(imageView.mas_bottom).offset(-32);
            make.left.mas_equalTo(20);
        }];
        
        UIImageView *littleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommed_decoration"]];
        [self.bgView addSubview:littleImageView];
        [littleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView).offset(39);
            make.right.mas_equalTo(-10);
            make.width.mas_equalTo(94);
            make.height.mas_equalTo(4);
        }];
    } else {
        maskImageView.hidden = YES;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(318);
        }];
        
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor hexColor:@"#D9D9D9"];
        contentView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.16].CGColor;
        contentView.layer.shadowOpacity = 1;
        contentView.layer.shadowOffset = CGSizeMake(0, 0);
        contentView.layer.shadowRadius = 3;
        [self.bgView addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(imageView);
            make.centerY.equalTo(imageView.mas_bottom);
        }];
        [contentLabel removeFromSuperview];
        [contentView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(40);
            make.bottom.mas_equalTo(-40);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView.mas_bottom).offset(14);
            make.left.mas_equalTo(10);
        }];
        
        UIImageView *rightBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommed_bar_right"]];
        [self.bgView addSubview:rightBarImageView];
        [rightBarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(timeLabel.mas_bottom).offset(20);
            make.right.mas_equalTo(0);
            make.width.mas_equalTo(321);
            make.height.mas_equalTo(5);
        }];
        
        UIImageView *barImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommed_bar_left"]];
        [self.bgView addSubview:barImageView];
        [barImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rightBarImageView.mas_bottom).offset(20);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(321);
            make.height.mas_equalTo(5);
            make.bottom.mas_lessThanOrEqualTo(-20);
        }];
    }
    self.synthesizer.delegate = self;
}

- (void)rightAction {
    CTTranslateViewController *vc = [[CTTranslateViewController alloc] initWithType:CTTranslateTypeText];
    vc.translateText = self.translateText;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)voiceAction {
    if (self.translateText.length == 0) {
        return;
    }
    if ([self.synthesizer isSpeaking]) {
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error) {
        NSLog(@"play voice error: %@", error.localizedDescription);
        return;
    }
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"play voice error: %@", error.localizedDescription);
        return;
    }
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.translateText];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en_US"];
    utterance.rate = 0.5;
    [self.synthesizer speakUtterance:utterance];
}

- (void)backAction {
    if (self.isHomeEnter) {
        [self displayBackAdvert];
    } else {
        [self jumpVCWithAnimated:YES];
    }
}

- (void)displayBackAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    __weak typeof(self) __self = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneBackHomeInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__self jumpVCWithAnimated:YES];
    }];
    [GADUtil.shared logScene:GADSceneBackHomeInter];
}

- (void)jumpVCWithAnimated:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:animated];
    });
}

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}

//TODO: AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"voice error: %@", error.localizedDescription);
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"voice error: %@", error.localizedDescription);
    }
}

#pragma  mark - UINavigationControllerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.isHomeEnter) {
        return YES;
    }
    [self displayBackAdvert];
    return NO;
}

@end
