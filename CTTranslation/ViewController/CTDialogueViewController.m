//
//  CTDialogueViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import "CTDialogueViewController.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTChangeLangugeView.h"
#import "CTTranslateManager.h"
#import <Speech/Speech.h>
#import "CTTranslation-Swift.h"
#import "CTTools.h"
#import "CTDialogueCell.h"
#import "UIButton+CTL.h"
#import "CTTranslateManager.h"
#import "CTDbHistoryHandle.h"
#import "CTTextView.h"

@interface CTDialogueViewController () <AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate, UIGestureRecognizerDelegate> {
//    NSUInteger playIndex;
}

@property (nonatomic, strong) CTChangeLangugeView *changeView;
//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *animationView;

@property (nonatomic, strong) CTTextView *sourceView;
@property (nonatomic, strong) CTTextView *targetView;
@property (nonatomic, strong) UIView *targetBarView;

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *speechRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *speechTask;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, assign) BOOL isRecognition;
@property (nonatomic, assign) BOOL isLeft;
@end

@implementation CTDialogueViewController

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
    [self stopRecording];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    [nav.leftButton removeTarget:nav action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [nav.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    nav.textLabel.text = @"Dialogue translation";
    [self.view addSubview:nav];
    [self.view addSubview:self.changeView];
    [self.changeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom).offset(15);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.changeView.mas_bottom).offset(5);
//        make.left.right.bottom.mas_equalTo(0);
//    }];
    
    
    [self.view addSubview:self.sourceView];
    [self.sourceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.changeView.mas_bottom).offset(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(130);
    }];

    [self.view addSubview:self.targetView];
    [self.targetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sourceView.mas_bottom).offset(20);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(223);
    }];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton nImage:[UIImage imageNamed:@"translate_delete"] hImage:nil];
    [deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.sourceView);
        make.height.width.mas_equalTo(38);
    }];
    
    self.targetBarView = [[UIView alloc] init];
    [self.view addSubview:self.targetBarView];
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
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton bgImage:[UIImage imageNamed:@"translate_voice_left"]];
    [leftButton setEnlargeEdge:10];
    [leftButton addTarget:self action:@selector(recognierStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    self.leftButton = leftButton;
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(79);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-CTSafeAreaBottom() - 20);
    }];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton bgImage:[UIImage imageNamed:@"translate_voice_right"]];
    [rightButton setEnlargeEdge:10];
    [rightButton addTarget:self action:@selector(recognierStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    self.rightButton = rightButton;
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-79);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-CTSafeAreaBottom() - 20);
    }];
    
    [self configureSpeech];
}

- (void)configureSpeech {
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.synthesizer.delegate = self;
}

- (void)recognierStartAction:(UIButton *)button {
    if (self.isRecognition) return;
    __weak typeof(self) weakSelf = self;
    [CTTools speechAndMicrophoneWithComplete:^(BOOL isSuccess, NSString * _Nullable message) {
        if (isSuccess) {
            if (weakSelf.synthesizer.isSpeaking) {
                [weakSelf.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                [weakSelf.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                return;
            }
            
            CTTranslateModel *model;
            if (self.leftButton == button) {
                self.isLeft = YES;
                model = self.changeView.sourceModel;
            } else {
                self.isLeft = NO;
                model = self.changeView.targetModel;
            }
            
            self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:model.identifier]];
            if (!self.speechRecognizer.isAvailable) {
                [UIView ct_tipToast:[NSString stringWithFormat:@"Does not support current language recognition: %@", model.name]];
                return;
            }
//            self.rightRecognizer.delegate = self;
            weakSelf.sourceView.text = @"";
            weakSelf.targetView.text = @"";
            [weakSelf startRecording];
            [weakSelf startVoiceAnimation:button];
        } else {
            if (message.length > 0) {
                [UIView ct_tipToast:message];
            }
        }
    }];
}

- (void)deleteAction {
    self.sourceView.text = @"";
    self.targetView.text = @"";
    [self.sourceView didValueChanged];
}

- (void)copyAction {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.targetView.text];
    [UIView ct_tipToast:@"Copy success!"];
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

- (void)voiceStopAction {
    [self stopVoiceAnimation];
    [self stopRecording];
}

- (void)startVoiceAnimation:(UIButton *)button {
    LottieAnimationView *lottieView = [LottieTools getLottieViewWith:self.isLeft ? @"left_voice" : @"right_voice" count:-1];
    self.animationView = (UIView *)lottieView;
    [self.view addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(button);
        make.centerX.equalTo(button);
        make.width.height.mas_equalTo(70);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceStopAction)];
    [self.animationView addGestureRecognizer:tap];
    [LottieTools playWithAnView:lottieView];
    button.hidden = YES;
}

- (void)stopVoiceAnimation {
    self.leftButton.hidden = NO;
    self.rightButton.hidden = NO;
    if (self.animationView) {
        LottieAnimationView *lottieView = (LottieAnimationView *)self.animationView;
        [LottieTools stopWithAnView:lottieView];
        [self.animationView removeFromSuperview];
        self.animationView = nil;
    }
}

- (void)appendDialogue:(NSString *)text {
    if (text.length == 0) return;
    CTTranslateModel *sourceModel = self.isLeft ? self.changeView.sourceModel : self.changeView.targetModel;
    CTTranslateModel *targetModel = self.isLeft ? self.changeView.targetModel : self.changeView.sourceModel;
    __weak typeof(self) weakSelf = self;
    [CTTranslateManager translateAsyncWithSource:sourceModel.language target:targetModel.language text:text complete:^(NSString * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf == nil) return;
            weakSelf.sourceView.text = [NSString stringWithFormat:@"%@ %@", weakSelf.sourceView.text, text];
            weakSelf.targetView.text = [NSString stringWithFormat:@"%@ %@", weakSelf.targetView.text, result];
            [weakSelf.sourceView didValueChanged];
            CTHistoryModel *historyModel = [CTDbHistoryHandle modelWithSourceModel:weakSelf.changeView.sourceModel targetModel:weakSelf.changeView.targetModel sourceText:text targetText:result];
            [CTDbHistoryHandle add:historyModel];
        });
    }];
}

//- (void)appendDialogue:(NSString *)text isLeft:(BOOL)isLeft {
//    if (text.length == 0) return;
//    CTTranslateModel *sourceModel = isLeft ? self.changeView.sourceModel : self.changeView.targetModel;
//    CTTranslateModel *targetModel = isLeft ? self.changeView.targetModel : self.changeView.sourceModel;
//    __weak typeof(self) weakSelf = self;
//    [CTTranslateManager translateAsyncWithSource:sourceModel.language target:targetModel.language text:text complete:^(NSString * _Nonnull result) {
//        ctdispatch_async_main_safe(^{
//            if (weakSelf == nil) return;
//            CTDialogueModel *model = [CTDialogueModel modelWithSourceText:text targetText:result sourceModel:sourceModel targetModel:targetModel isLeft:isLeft];
//            [weakSelf.dataSource addObject:model];
//            [weakSelf.tableView reloadData];
//            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:weakSelf.dataSource.count - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            
//            CTHistoryModel *historyModel = [CTDbHistoryHandle modelWithSourceModel:weakSelf.changeView.sourceModel targetModel:weakSelf.changeView.targetModel sourceText:text targetText:result];
//            [CTDbHistoryHandle add:historyModel];
//        });
//    }];
//}

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
    
    self.speechRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    if (@available(iOS 16, *)) {
        self.speechRequest.addsPunctuation = YES;
    }
    if (self.speechRecognizer.supportsOnDeviceRecognition) {
        self.speechRequest.requiresOnDeviceRecognition = YES;
    }
    self.speechRequest.shouldReportPartialResults = YES;
    
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.speechRequest appendAudioPCMBuffer:buffer];
    }];
    
    self.isRecognition = YES;
    __weak typeof(self) weakSelf = self;
    self.speechTask = [self.speechRecognizer recognitionTaskWithRequest:self.speechRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        BOOL isFinal = NO;
        if (result) {
            if (result.bestTranscription.segments.firstObject.confidence > 0) {
                NSString *text = result.bestTranscription.formattedString;
                NSLog(@"<Speech> recognizer result:%@", text);
                if (text.length > 0) {
                    [strongSelf appendDialogue:text];
                }
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
    if (self.audioEngine.isRunning && self.isRecognition) {
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

- (void)backAction {
    [self displayBackAdvert];
}

- (void)displayBackAdvert {
    __weak typeof(self) __weakself = self;
    [GADUtil.shared load:GADPositionInterstital p:GADSceneBackHomeInter completion:nil];
    [GADUtil.shared show:GADPositionInterstital p:GADSceneBackHomeInter from:self completion:^(GADBaseModel * _Nullable model) {
        [__weakself jumpVCWithAnimated:YES];
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
        _sourceView.editable = NO;
        _sourceView.textContainerInset = UIEdgeInsetsMake(15, 15, 40, 39);
    }
    return _sourceView;
}

- (CTTextView *)targetView {
    if (!_targetView) {
        _targetView = [[CTTextView alloc] init];
        _targetView.editable = NO;
    }
    return _targetView;
}



- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}

//TODO: AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
//    [self stopPlayVoice];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"voice error: %@", error.localizedDescription);
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
//    [self stopPlayVoice];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"voice error: %@", error.localizedDescription);
    }
}

//TODO: SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    if (available) {
        NSLog(@"voice: speech valid");
    } else {
        NSLog(@"voice: speech invalid");
    }
}

#pragma  mark - UINavigationControllerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self displayBackAdvert];
    return NO;
}

@end
