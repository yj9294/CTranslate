//
//  CTTranslateViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTTranslateViewController.h"
#import "CTCameraViewController.h"
#import "CTChangeLangugeView.h"
#import "CTNavigationView.h"
#import "CTTextView.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"
#import "CTTools.h"
#import "CTTranslateManager.h"
#import <Speech/Speech.h>
#import "CTTranslation-Swift.h"
#import "CTDbHistoryHandle.h"
#import "CTTextPop.h"
#import "CTVoicePop.h"
#import "CTCameraPop.h"

#import <AVFoundation/AVFoundation.h>


@interface CTTranslateViewController () <AVSpeechSynthesizerDelegate, UIGestureRecognizerDelegate, GADNativeAdDelegate>

@property (nonatomic, strong) CTChangeLangugeView *changeView;
@property (nonatomic, strong) CTTextView *sourceView;
@property (nonatomic, strong) CTTextView *targetView;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIView *targetBarView;

@property (nonatomic, strong) UIView *bannerBgView;
@property (nonatomic, strong) UIImageView *bgAdImageView;

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *speechRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *speechTask;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, assign) BOOL isRecognition;
@property (nonatomic, assign) BOOL isPop;

@property (nonatomic, strong) NSString *sourceText;
@property (nonatomic, strong) NSString *targetText;

@property (nonatomic, strong, nullable) GADNativeAdView *nativeAdView;
@end

@implementation CTTranslateViewController

- (void)didVC {
    [super didVC];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (id)initWithType:(CTTranslateType)type {
    if (self = [super init]) {
        self.translateType = type;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.synthesizer isSpeaking]) {
        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    [GADUtil.shared disappear:GADPositionNative];
    [GADUtil.shared disappear:GADPositionBanner];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addADNotification];
    
    [self guidMask];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    NSString *navTitle;
    if (self.translateType == CTTranslateTypeText) {
        navTitle = @"Text Translate";
    } else if (self.translateType == CTTranslateTypeVoice) {
        navTitle = @"Voice Translate";
    } else {
        navTitle = @"Camera Translate";
    }
    nav.textLabel.text = navTitle;
    [self.view addSubview:nav];
    
    CGFloat nativeHeight = 0;
    CGFloat bannerHeight = 0;
    CGFloat contentHeight = CTScreenHeight() - CTNavHeight() - 15;
    bannerHeight = 80;
    contentHeight -= 90;
    self.bannerBgView = [[UIView alloc] init];
    self.bannerBgView.layer.cornerRadius = 15;
    self.bannerBgView.userInteractionEnabled = YES;
    self.bannerBgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    [self.view addSubview:self.bannerBgView];
    [self.bannerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(bannerHeight);
    }];
    
    nativeHeight = 152;
    contentHeight = contentHeight - CTBottom() - nativeHeight - 10;
    self.bgAdImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"advert_small_bg"]];
    self.bgAdImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgAdImageView];
    [self.bgAdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-CTBottom());
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(nativeHeight);
    }];
    
    self.nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"NativeAdSmallView" owner:nil options:nil].firstObject;
    [self.nativeAdView setHidden:YES];
    [self.bgAdImageView addSubview:self.nativeAdView];
    [self.nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.bgAdImageView);
    }];

    CGFloat textHeight = contentHeight - 60;
    if (self.translateType == CTTranslateTypeVoice) {
        textHeight -= 131;
    } else {
        textHeight -= 76;
    }
    textHeight = textHeight / 2;
    CGFloat sourceHeight = textHeight - 10;
    CGFloat targetHeight = textHeight + 10;
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = self.view.backgroundColor;
    BOOL isSmallScrren = CTScreenHeight() < 736;
    if (isSmallScrren) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = self.view.backgroundColor;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = YES;
        [self.view addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nav.mas_bottom).offset(105);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(contentHeight);
        }];
        
        [scrollView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.width.equalTo(scrollView);
            make.height.greaterThanOrEqualTo(scrollView);
        }];
        if (self.translateType == CTTranslateTypeVoice) {
            sourceHeight = 90;
            targetHeight = 115;
        } else {
            sourceHeight = 120;
            targetHeight = 139;
        }
    } else {
        [self.view addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nav.mas_bottom).offset(105);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(contentHeight);
        }];
    }
    
    [bgView addSubview:self.changeView];
    [self.changeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [bgView addSubview:self.sourceView];
    [self.sourceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.changeView.mas_bottom).offset(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(sourceHeight);
    }];
    
    [bgView addSubview:self.translateButton];
    [bgView addSubview:self.targetView];
    [self.targetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.translateButton.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(targetHeight);
        if (isSmallScrren) {
            make.bottom.mas_equalTo(0);
        }
    }];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton nImage:[UIImage imageNamed:@"translate_delete"] hImage:nil];
    [deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.sourceView);
        make.height.width.mas_equalTo(38);
    }];
    
    self.targetBarView = [[UIView alloc] init];
    [bgView addSubview:self.targetBarView];
    self.targetBarView.hidden = YES;
    [self.targetBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.targetView);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(55);
    }];
    
    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyButton bgImage:[UIImage imageNamed:@"translate_copy"]];
    [copyButton setEnlargeEdge:10];
    [copyButton addTarget:self action:@selector(copyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.targetBarView addSubview:copyButton];
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.width.height.mas_equalTo(25);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"translate_target_line"]];
    [self.targetBarView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(copyButton);
        make.right.equalTo(copyButton.mas_left).offset(-25);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(25);
    }];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton bgImage:[UIImage imageNamed:@"translate_play"]];
    [playButton setEnlargeEdge:10];
    [playButton addTarget:self action:@selector(voicePlayAction) forControlEvents:UIControlEventTouchUpInside];
    [self.targetBarView addSubview:playButton];
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(copyButton);
        make.width.height.mas_equalTo(25);
        make.right.equalTo(lineView.mas_left).offset(-15);
    }];
    
    if (self.translateType == CTTranslateTypeText) {
        [self.translateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sourceView.mas_bottom).offset(15);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(274);
            make.height.mas_equalTo(46);
        }];
    } else if (self.translateType == CTTranslateTypeVoice) {
        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [voiceButton bgImage:[UIImage imageNamed:@"translate_voice_left"]];
        [voiceButton setEnlargeEdge:10];
        [voiceButton addTarget:self action:@selector(voiceStartAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:voiceButton];
        self.voiceButton = voiceButton;
        [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.sourceView).offset(25);
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(50);
        }];
        
        UILabel *voiceLabel = [UILabel lbText:@"Click on the microphone to record" font:[UIFont fontWithSize:14] color:[UIColor whiteColor]];
        [self.view addSubview:voiceLabel];
        [voiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(voiceButton.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        [self.translateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sourceView.mas_bottom).offset(70);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(274);
            make.height.mas_equalTo(46);
        }];
    } else {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton nImage:[UIImage imageNamed:@"translate_camera"] hImage:nil];
        [rightButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
        [nav addSubview:rightButton];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(44);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-6);
        }];
        
        [self.translateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sourceView.mas_bottom).offset(15);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(274);
            make.height.mas_equalTo(46);
        }];
    }
    
    if (self.translateText.length > 0) {
        self.sourceView.text = self.translateText;
        [self.sourceView didValueChanged];
    }
    
    [self configureSpeech];
    
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    [GADUtil.shared load:GADPositionInterstital p:GADSceneResultInter completion:nil];
    [GADUtil.shared disappear:GADPositionNative];
    [GADUtil.shared disappear:GADPositionBanner];
    [GADUtil.shared load:GADPositionNative p:GADSceneTranslateNative completion:nil];
    [GADUtil.shared load:GADPositionBanner p:GADSceneTranslateBanner completion:nil];
    
    [GADUtil.shared logScene:GADSceneTranslateBanner];
    [GADUtil.shared logScene:GADSceneTranslateNative];
}

- (void)addADNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nativeAdUpdate:) name:@"homeNativeUpdate" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(bannerAdUpdate:) name:@"banner.ad" object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)guidMask {
    if (![GADUtil.shared isGuideConfig]) {
        return;
    }
    if (self.translateType == CTTranslateTypeText) {
        if ([AppManager.shared getNeedTextGuide]) {
            self.sourceView.text = @"Hello!";
            [self.sourceView didValueChanged];
            self.isPop = YES;
            CTTextPop *pop = [[CTTextPop alloc] init];
            [pop showWithComplete:^{
                [self translateAction];
            }];
        }
    } else if (self.translateType == CTTranslateTypeVoice) {
        if ([AppManager.shared getNeedVoiceGuide]) {
            self.sourceView.text = @"Hello!";
            [self.sourceView didValueChanged];
            self.isPop = YES;
            CTVoicePop *pop = [[CTVoicePop alloc] init];
            [pop showWithComplete:^{
                [self translateAction];
            }];
        }
    } else if (self.translateType == CTTranslateTypeCamera) {
        if ([AppManager.shared getNeedCameraGuide]) {
            self.sourceView.text = @"Everything will be ok in the end, if it's not ok, it's not the end.";
            [self.sourceView didValueChanged];
            self.isPop = YES;
            CTCameraPop *pop = [[CTCameraPop alloc] init];
            [pop showWithComplete:^{
                [self translateAction];
            }];
        }
    }
}

- (void)configureSpeech {
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:self.changeView.sourceModel.identifier]];
    __weak typeof(self) weakSelf = self;
    self.changeView.sourceChange = ^(NSString * _Nonnull text) {
        weakSelf.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:text]];
    };
    self.changeView.targetChange = ^(NSString * _Nonnull text) {
        
    };
    self.synthesizer.delegate = self;
}

- (void)deleteAction {
    self.sourceView.text = @"";
    [self.sourceView didValueChanged];
}

- (void)cameraAction:(UIButton *)button {
    //判断权限
    __weak typeof(self) weakSelf = self;
    [CTTools cameraAuthWithComplete:^(BOOL isSuccess, NSString * _Nullable message) {
        if (isSuccess) {
            CTCameraViewController *vc = [[CTCameraViewController alloc] initWithSource:weakSelf.changeView.sourceModel target:weakSelf.changeView.targetModel];
            vc.ocrComplete = ^(NSString * _Nonnull sourceText, NSString * _Nonnull targetText) {
                [UIView ct_tipToast:@"Image recognition in progress..."];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.sourceText = sourceText;
                    weakSelf.targetText = targetText;
                    [weakSelf displayTranslateAdvert];
                });
            };
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            if (message.length > 0) {
                [UIView ct_tipToast:message];
            }
        }
    }];
}

- (void)translateAction {
    [self.sourceView resignFirstResponder];
    if (self.sourceView.text.length == 0) {
        [UIView ct_tipToast:@"No Content!"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [CTTranslateManager translateAsyncWithSource:self.changeView.sourceModel.language target:self.changeView.targetModel.language text:self.sourceView.text complete:^(NSString * _Nonnull result) {
        weakSelf.sourceText = weakSelf.sourceView.text;
        weakSelf.targetText = result;
        ctdispatch_async_main_safe(^{
            [weakSelf displayTranslateAdvert];
            //保存数据库
            CTHistoryModel *historyModel = [CTDbHistoryHandle modelWithSourceModel:weakSelf.changeView.sourceModel targetModel:weakSelf.changeView.targetModel sourceText:weakSelf.sourceView.text targetText:result];
            [CTDbHistoryHandle add:historyModel];
        })
    }];
}

- (void)voicePlayAction {
    if (self.isRecognition) return;
    if (self.targetView.text.length == 0) return;
    
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
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.targetView.text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.changeView.targetModel.identifier];
    utterance.rate = 0.5;
    [self.synthesizer speakUtterance:utterance];
}

- (void)copyAction {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.targetView.text];
    [UIView ct_tipToast:@"Copy success!"];
}

- (void)voiceStartAction {
    if (self.isRecognition) return;
    __weak typeof(self) weakSelf = self;
    [CTTools speechAndMicrophoneWithComplete:^(BOOL isSuccess, NSString * _Nullable message) {
        if (isSuccess) {
            if (weakSelf.synthesizer.isSpeaking) {
                [weakSelf.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                [weakSelf.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                return;
            }
            [weakSelf startRecording];
            [weakSelf startVoiceAnimation];
            weakSelf.sourceView.text = @"";
            [weakSelf.sourceView didValueChanged];
        } else {
            if (message.length > 0) {
                [UIView ct_tipToast:message];
            }
        }
    }];
}

- (void)voiceStopAction {
    [self stopVoiceAnimation];
    [self stopRecording];
}

- (void)startVoiceAnimation {
    LottieAnimationView *lottieView = [LottieTools getLottieViewWith:@"left_voice" count:-1];
    self.animationView = (UIView *)lottieView;
    [self.view addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.voiceButton);
        make.centerX.equalTo(self.voiceButton);
        make.width.height.mas_equalTo(70);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceStopAction)];
    [self.animationView addGestureRecognizer:tap];
    [LottieTools playWithAnView:lottieView];
    self.voiceButton.hidden = YES;
}

- (void)stopVoiceAnimation {
    self.voiceButton.hidden = NO;
    if (self.animationView) {
        LottieAnimationView *lottieView = (LottieAnimationView *)self.animationView;
        [LottieTools stopWithAnView:lottieView];
        [self.animationView removeFromSuperview];
        self.animationView = nil;
    }
}

- (void)startRecording {
    if (self.audioEngine.isRunning) {
        [self stopRecording];
        return;
    }
    
    if (self.speechTask) {
        [self.speechTask cancel];
        self.speechTask = nil;
    }
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    self.audioSession = audioSession;
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error) {
        NSLog(@"<Speech> record error:%@", error.localizedDescription);
        return;
    }
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"<Speech> record error:%@", error.localizedDescription);
        return;
    }
    
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.speechRequest appendAudioPCMBuffer:buffer];
    }];
    
    self.speechRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    if (@available(iOS 16, *)) {
        self.speechRequest.addsPunctuation = YES;
    }
    if (self.speechRecognizer.supportsOnDeviceRecognition) {
        self.speechRequest.requiresOnDeviceRecognition = YES;
    }
    self.speechRequest.shouldReportPartialResults = YES;
    self.isRecognition = YES;
    
    __weak typeof(self) weakSelf = self;
    self.speechTask = [self.speechRecognizer recognitionTaskWithRequest:self.speechRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        BOOL isFinal = NO;
        if (result) {
            NSLog(@"<Speech> recognizer result:%@", result.bestTranscription.formattedString);
            if (result.bestTranscription.segments.firstObject.confidence > 0) {
                strongSelf.sourceView.text = [NSString stringWithFormat:@"%@%@", strongSelf.sourceView.text, result.bestTranscription.formattedString];
                [strongSelf.sourceView didValueChanged];
            }
            
            isFinal = result.isFinal;
        }
        
        if (error) {
            NSLog(@"<Speech> :%@", error.localizedDescription);
        }
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    if (error) {
        NSLog(@"<Speech> error:%@", error.localizedDescription);
    } else {
        NSLog(@"<Speech> start speech recognizer");
    }
}

- (void)stopRecording {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        
        [self.speechRequest endAudio];
        [self.speechTask finish];
        self.speechRequest = nil;
        self.speechTask = nil;
        
        [self.audioEngine.inputNode removeTapOnBus:0];
        [self.audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        self.audioSession = nil;
        self.isRecognition = NO;
        NSLog(@"<Speech> stop record audio");
    }
}

- (void)nativeAdUpdate:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    if ([model isKindOfClass:GADNativeModel.class] && model.p == GADSceneTranslateNative) {
        GADNativeModel *nativeModel = (GADNativeModel *)model;
        if (nativeModel.nativeAd) {
            [self.bgAdImageView setHidden:false];
            [self.nativeAdView setHidden:false];
            [self addNativeViewWithNativeAd:nativeModel.nativeAd];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-CTBottom());
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(152);
            }];
        } else {
            [self.bgAdImageView setHidden:true];
            [self.nativeAdView setHidden:true];
            [self.bgAdImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-CTBottom());
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(0);
            }];
        }
    }
}

- (void)bannerAdUpdate:(NSNotification *)noti {
    GADBaseModel *model = (GADBaseModel *)noti.object;
    if ([model isKindOfClass:GADBannerModel.class] && model.p == GADSceneTranslateBanner) {
        GADBannerModel *nativeModel = (GADBannerModel *)model;
        if (nativeModel.bannerView) {
            [self.bannerBgView setHidden:false];
            [self.bannerBgView addSubview:nativeModel.bannerView];
            [nativeModel.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.bottom.equalTo(self.bannerBgView);
            }];
            [self.bannerBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15 + 44);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(80);
            }];
        } else {
            [self.bannerBgView setHidden:true];
            [self.bannerBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_topMargin).offset(15 + 44);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(0);
            }];
        }
    }
}

- (void)addNativeViewWithNativeAd:(GADNativeAd *)nativeAd {
    self.nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
    self.nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    ((UILabel *)(self.nativeAdView.headlineView)).text = nativeAd.headline;
    
    ((UILabel *)self.nativeAdView.bodyView).text = nativeAd.body;
    self.nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
    
    [((UIButton *)self.nativeAdView.callToActionView) setTitle:nativeAd.callToAction forState:UIControlStateNormal];
    self.nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
    
    ((UIImageView *)self.nativeAdView.iconView).image = nativeAd.icon.image;
    self.nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

//    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
//    nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

    ((UILabel *)self.nativeAdView.storeView).text = nativeAd.store;
    self.nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)self.nativeAdView.priceView).text = nativeAd.price;
    self.nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

    ((UILabel *)self.nativeAdView.advertiserView).text = nativeAd.advertiser;
    self.nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
    
    self.nativeAdView.callToActionView.userInteractionEnabled = NO;
    self.nativeAdView.nativeAd = nativeAd;
}

- (void)backAction {
    [self displayBackAdvert];
}

- (void)displayTranslateAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneResultInter completion:nil];
    __weak  typeof(self) __self = self;
    [GADUtil.shared show:GADPositionInterstital p:GADSceneResultInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__self translateResult];
    }];
    [GADUtil.shared logScene:GADSceneResultInter];
}

- (void)translateResult {
    self.sourceView.text = self.sourceText;
    self.targetView.text = self.targetText;
    if (self.targetView.isHidden) {
        self.targetView.hidden = NO;
        self.targetBarView.hidden = NO;
    }
    self.sourceText = @"";
    self.targetText = @"";
}

- (void)displayBackAdvert {
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    __weak  typeof(self) __self = self;
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

//TODO: getter
- (CTChangeLangugeView *)changeView {
    if (!_changeView) {
        _changeView = [[CTChangeLangugeView alloc] init];
    }
    return _changeView;
}

- (CTTextView *)sourceView {
    if (!_sourceView) {
        _sourceView = [[CTTextView alloc] init];
        [_sourceView configPlaceholder:@"Enter text here..." font:[UIFont fontWithSize:15] textColor:[UIColor colorWithWhite:1 alpha:0.6]];
        _sourceView.textContainerInset = UIEdgeInsetsMake(15, 15, 40, 39);
    }
    return _sourceView;
}

- (CTTextView *)targetView {
    if (!_targetView) {
        _targetView = [[CTTextView alloc] init];
        _targetView.editable = NO;
        _targetView.hidden = YES;
    }
    return _targetView;
}

- (UIButton *)translateButton {
    if (!_translateButton) {
        _translateButton = [UIButton btTitle:@"Translate"];
        [_translateButton addTarget:self action:@selector(translateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _translateButton;
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
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self displayBackAdvert];
    return NO;
}
@end
