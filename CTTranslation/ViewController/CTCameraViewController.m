//
//  CTCameraViewController.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import "CTCameraViewController.h"
#import "CTNavigationView.h"
#import "UIView+CT.h"
#import "CTTranslateManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CTTools.h"
#import "CTDbHistoryHandle.h"

@interface CTCameraViewController () <AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) CTTranslateModel *sourceModel;
@property (nonatomic, strong) CTTranslateModel *targetModel;

@property (nonatomic, strong) UIButton *lightButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takeButton;
@property (nonatomic, strong) UIButton *reTakeButton;
@property (nonatomic, strong) UIButton *completeButton;

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImage *selectImage;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) dispatch_queue_t captureQueue;

@end

@implementation CTCameraViewController

- (id)initWithSource:(CTTranslateModel *)sourceModel target:(CTTranslateModel *)targetModel {
    if (self = [super init]) {
        self.sourceModel = sourceModel;
        self.targetModel = targetModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hexColor:@"#12263A"];
    CTNavigationView *nav = [[CTNavigationView alloc] init];
    nav.textLabel.text = @"Camera Translate";
    [self.view addSubview:nav];
    [nav addSubview:self.lightButton];
    [self.lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.width.height.mas_equalTo(42);
        make.centerY.mas_equalTo(0);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (CTSafeAreaBottom() > 0) {
            make.bottom.mas_equalTo(-25);
        } else {
            make.bottom.mas_equalTo(0);
        }
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(96);
    }];
    
    [bottomView addSubview:self.photoButton];
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(55);
        make.left.mas_equalTo(0);
    }];
    [bottomView addSubview:self.takeButton];
    [self.takeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(56);
        make.centerX.mas_equalTo(0);
    }];
    [bottomView addSubview:self.reTakeButton];
    [self.reTakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(133);
        make.height.mas_equalTo(56);
    }];
    [bottomView addSubview:self.completeButton];
    [self.completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(55);
        make.right.mas_equalTo(0);
    }];
    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.hidden = YES;
    self.photoImageView.clipsToBounds = YES;
    [self.view addSubview:self.photoImageView];
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nav.mas_bottom);
        make.bottom.equalTo(bottomView.mas_top);
        make.left.right.mas_equalTo(0);
    }];
    [self captureConfigure];
}

- (void)captureConfigure {
    self.captureQueue = dispatch_queue_create("com.co.translate.photo", DISPATCH_QUEUE_CONCURRENT);
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }
    if (error) {
        NSLog(@"<Camera> error:%@", error.localizedDescription);
    }
    
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    CGRect rect = self.view.layer.bounds;
    rect.origin.y = CTNavHeight();
    rect.size.height = rect.size.height - CTNavHeight() - 96;
    if (CTSafeAreaBottom() > 0) {
        rect.size.height -= 25;
    }
    self.previewLayer.frame = rect;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self startCapture];
}

- (void)startCapture {
    if (![self.captureSession isRunning]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(self.captureQueue, ^{
            [weakSelf.captureSession startRunning];
        });
    }
}

- (void)stopCapture {
    if ([self.captureSession isRunning]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(self.captureQueue, ^{
            [weakSelf.captureSession stopRunning];
        });
    }
    if (self.lightButton.isSelected) {
        [self lightAction];
    }
}

//TODO: Action
- (void)lightAction {
    NSError *error;
    [self.captureDevice lockForConfiguration:&error];
    if (!error) {
        if ([self.captureDevice hasTorch]) {
            if (self.captureDevice.torchMode == AVCaptureTorchModeOn) {
                self.captureDevice.torchMode = AVCaptureTorchModeOff;
                self.lightButton.selected = NO;
            } else if (self.captureDevice.torchMode == AVCaptureTorchModeOff) {
                self.captureDevice.torchMode = AVCaptureTorchModeOn;
                self.lightButton.selected = YES;
            }
        }
        [self.captureDevice unlockForConfiguration];
    }
}

- (void)photoAction {
    __weak typeof(self) weakSelf = self;
    [CTTools albumAuthWithComplete:^(BOOL isSuccess, NSString * _Nullable message) {
        if (isSuccess) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = weakSelf;
            picker.modalPresentationStyle = UIModalPresentationCustom;
            [weakSelf presentViewController:picker animated:YES completion:nil];
            [weakSelf stopCapture];
        } else {
            if (message.length > 0) {
                [UIView ct_tipToast:message];
            }
        }
    }];
}

- (void)takeAction {
    AVCapturePhotoSettings *settings = [[AVCapturePhotoSettings alloc] init];
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)reTakeAction {
    [self photoWithIsCapture:NO];
    [self startCapture];
    self.selectImage = nil;
    if (!self.photoImageView.isHidden) {
        self.photoImageView.image = nil;
        self.photoImageView.hidden = YES;
    }
}

- (void)completeAction {
    [UIView ct_showLoading:@"Identifying..."];
    __weak typeof(self) weakSelf = self;
    [CTTranslateManager translateAndRecognizerWithImage:self.selectImage source:self.sourceModel target:self.targetModel complete:^(NSString * _Nonnull recognizerText, NSString * _Nonnull result) {
        ctdispatch_async_main_safe(^{
            [UIView ct_hideLoading];
            if (recognizerText.length == 0) {
                [UIView ct_tipToast:@"Sorry, Recognizer failed!"];
                return;
            } else {
                CTHistoryModel *historyModel = [CTDbHistoryHandle modelWithSourceModel:weakSelf.sourceModel targetModel:weakSelf.targetModel sourceText:recognizerText targetText:result];
                [CTDbHistoryHandle add:historyModel];
                if (weakSelf.ocrComplete) weakSelf.ocrComplete(recognizerText, result);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}

- (void)photoWithIsCapture:(BOOL)isCapture {
    self.reTakeButton.hidden = !isCapture;
    self.completeButton.hidden = !isCapture;
    self.takeButton.hidden = isCapture;
}

//TODO: Getter
- (UIButton *)lightButton {
    if (!_lightButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button nImage:[UIImage imageNamed:@"camera_light_no"] hImage:[UIImage imageNamed:@"camera_light"]];
        [button addTarget:self action:@selector(lightAction) forControlEvents:UIControlEventTouchUpInside];
        _lightButton = button;
    }
    return _lightButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button nImage:[UIImage imageNamed:@"camera_photo"] hImage:nil];
        [button addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
        _photoButton = button;
    }
    return _photoButton;
}

- (UIButton *)takeButton {
    if (!_takeButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button nImage:[UIImage imageNamed:@"camera_take"] hImage:nil];
        [button addTarget:self action:@selector(takeAction) forControlEvents:UIControlEventTouchUpInside];
        _takeButton = button;
    }
    return _takeButton;
}

- (UIButton *)reTakeButton {
    if (!_reTakeButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Retake" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithSize:17 weight:UIFontWeightMedium];
        button.layer.cornerRadius = 28;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 2;
        button.layer.masksToBounds = YES;
        button.hidden = YES;
        [button addTarget:self action:@selector(reTakeAction) forControlEvents:UIControlEventTouchUpInside];
        _reTakeButton = button;
    }
    return _reTakeButton;
}

- (UIButton *)completeButton {
    if (!_completeButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button nImage:[UIImage imageNamed:@"camera_complete"] hImage:nil];
        button.hidden = YES;
        [button addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
        _completeButton = button;
    }
    return _completeButton;
}

//TODO: AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    NSData *data = [photo fileDataRepresentation];
    if (!data) return;
    UIImage *image = [UIImage imageWithData:data];
    if (!image) return;
    [self stopCapture];
    self.selectImage = image;
    [self photoWithIsCapture:YES];
}

//TODO: UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self startCapture];
    [self photoWithIsCapture:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        self.selectImage = image;
        self.photoImageView.image = image;
        self.photoImageView.hidden = NO;
        [self photoWithIsCapture:YES];
    } else {
        [self startCapture];
        [self photoWithIsCapture:NO];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
