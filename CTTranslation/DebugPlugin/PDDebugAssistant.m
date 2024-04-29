//
//  PDDebugAssistant.m
//  SunUIKit
//
//  Created by cttranslation on 2020/7/30.
//

#import "PDDebugAssistant.h"
#import "PDLogManager.h"
#import "PDUITools.h"
#import <objc/runtime.h>
#import "Masonry.h"

//多次调用会出故障
static BOOL isInit = NO;

@interface PDDebugAssistant ()
@property (nonatomic, strong) PDDebugWindow *debugWindow;
@end

@implementation PDDebugAssistant

// 启动Debug
+ (void)fire {
    if (isInit) return;
    isInit = YES;
    
    void(^fire)(void) = ^{
        [PDLogManager configure];
#ifdef DEBUG
        [[PDDebugAssistant shared].debugWindow show];
#else
        [[PDDebugAssistant shared].debugWindow dismiss];
#endif
    };
    
    if ([NSThread isMainThread]) {
        fire();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            fire();
        });
    }
}

+ (void)invalidate {
    [[PDDebugAssistant shared].debugWindow dismiss];
}

+ (nonnull PDDebugAssistant *)shared {
    static dispatch_once_t once;
    static PDDebugAssistant *instance;
    dispatch_once(&once, ^{
        instance = [PDDebugAssistant new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat w = 48;
        CGFloat h = 48;
        CGFloat x = PDScreenWidth() - w - 5;
        CGFloat y = PDScreenHeight() - PDSafeAreaBottom() - h - 50;
        self.debugWindow = [[PDDebugWindow alloc] initWithFrame:CGRectMake(x, y, w, h)];
    }
    return self;
}

@end

@interface PDDebugWindow ()
@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, strong) PDDebugPanel *debugPanel;
@end

@implementation PDDebugWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 13.0, *)) {
            UIScene *scene = [[UIApplication sharedApplication].connectedScenes anyObject];
            if (scene) {
                self.windowScene = (UIWindowScene *)scene;
            }
        }
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 100;
        self.layer.masksToBounds = YES;
        
        if (!self.rootViewController) {
            self.rootViewController = [UIViewController new];
            [self.rootViewController.view addSubview:self.debugButton];
        }
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGest:)];
        [self addGestureRecognizer:pan];
        
        [[PDUITools getRootWindow] addSubview:self.debugPanel];
    }
    return self;
}

- (void)show {
    self.hidden = NO;
}

- (void)dismiss {
    self.hidden = YES;
}

#pragma mark - Events
- (void)onPanGest:(UIPanGestureRecognizer *)gest {
    switch (gest.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gest translationInView:gest.view];
            [gest setTranslation:CGPointZero inView:gest.view];
            [gest.view setCenter:CGPointMake(gest.view.center.x + translation.x, gest.view.center.y + translation.y)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGRect edge = PDAssistantMaxEdge();
            CGRect frame = gest.view.frame;
            frame.origin.x = gest.view.center.x < PDScreenWidth() / 2 ? edge.origin.x : CGRectGetMaxX(edge) - frame.size.width;
            frame.origin.y = MIN(MAX(frame.origin.y, edge.origin.y), CGRectGetMaxY(edge) - frame.size.height);
            [UIView animateWithDuration:0.25 animations:^{
                gest.view.frame = frame;
            }];
        }
        default:
            break;
    }
}

- (void)debugAction {
    [self.debugPanel setHidden:!self.debugPanel.isHidden];
    if (!self.debugPanel.isHidden) {
        CGRect rect = self.debugPanel.frame;
        rect.origin.y = PDScreenHeight() - rect.size.height;
        self.debugPanel.frame = rect;
        [[PDUITools getRootWindow] bringSubviewToFront:self.debugPanel];
    } else {
        [PDFullScreenTextViewer dismiss];
        CGRect rect = self.debugPanel.frame;
        rect.origin.y = PDScreenHeight();
        self.debugPanel.frame = rect;
    }
}

#pragma mark - Getters
- (UIButton *)debugButton {
    if (!_debugButton) {
        _debugButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_debugButton setFrame:self.bounds];
        [_debugButton setTitle:@"DEBUG" forState:UIControlStateNormal];
        [_debugButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _debugButton.layer.cornerRadius = 2;
        _debugButton.layer.masksToBounds = YES;
        [_debugButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_debugButton addTarget:self action:@selector(debugAction) forControlEvents:UIControlEventTouchUpInside];
        
        CAGradientLayer *gradient = [CAGradientLayer new];
        [gradient setFrame:self.bounds];
        [gradient setColors:@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]];
        gradient.startPoint = CGPointMake(0.0, 0.0);
        gradient.endPoint = CGPointMake(1.0, 0.0);
        [_debugButton.layer insertSublayer:gradient atIndex:0];
    }
    return _debugButton;
}

- (PDDebugPanel *)debugPanel {
    if (!_debugPanel) {
        _debugPanel = [PDDebugPanel new];
        [_debugPanel setHidden:YES];
    }
    return _debugPanel;
}

@end

@interface PDDebugPanel ()
@property (nonatomic, strong) UISegmentedControl *segControl;
@property (nonatomic, strong) PDNetList *netList;
@property (nonatomic, strong) PDLogList *logList;
@property (nonatomic, strong) NSArray<NSString *> *segTitles;
@property (nonatomic, strong) UIButton *uploadButton;
@end

@implementation PDDebugPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    CGRect rect = self.frame;
    rect.size = CGSizeMake(PDScreenWidth(), PDScreenHeight() * 0.6);
    rect.origin.y = PDScreenHeight() - rect.size.height;
    self.frame = rect;
    [self setBackgroundColor:[PDUITools colorWithHex:0xF4F4F4 alpha:1.0f]];
    
    [self addSubview:self.segControl];
    [self addSubview:self.netList];
    [self addSubview:self.logList];
    [self addSubview:self.uploadButton];
    
    // 监听KeyWindow的根控制器变化，防止调试浮窗被阻挡
    [[PDUITools getRootWindow] addObserver:self forKeyPath:@"rootViewController" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [[PDUITools getRootWindow] removeObserver:self forKeyPath:@"rootViewController"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:[PDUITools getRootWindow]]) {
        [[PDUITools getRootWindow] bringSubviewToFront:self];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

#pragma mark - Events
// 点击Segment
- (void)handleSegment:(UISegmentedControl *)segment {
    NSInteger index = segment.selectedSegmentIndex;
    if (index == 0) {
        self.uploadButton.hidden = YES;
    } else {
        self.uploadButton.hidden = NO;
    }
    [self.segTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[self viewWithTag:100 + idx] setHidden:idx != index];
    }];
}

- (void)uploadAction {
    [PDUITools sendLogsToChat:self.logList.logs complete:^(BOOL isSuccess) {
        if (isSuccess) {
            [[PDLogManager shared] clearLogs];
        }
    }];
}

#pragma mark - Getters
- (NSArray<NSString *> *)segTitles {
    return @[@"network", @"logs"];
}

- (UISegmentedControl *)segControl {
    if (!_segControl) {
        _segControl = [[UISegmentedControl alloc] initWithItems:self.segTitles];
        _segControl.backgroundColor = [PDUITools colorWithHex:0x3D5588 alpha:1];
        CGRect rect = _segControl.frame;
        rect.origin.y = 10;
        rect.origin.x = self.frame.size.width / 2 - rect.size.width * 0.5;
        _segControl.frame = rect;
        [_segControl addTarget:self action:@selector(handleSegment:) forControlEvents:UIControlEventValueChanged];
        [_segControl setSelectedSegmentIndex:0];
    }
    return _segControl;
}

- (PDNetList *)netList {
    if (!_netList) {
        CGFloat top = self.segControl.frame.origin.y + self.segControl.frame.size.height + 10;
        _netList = [[PDNetList alloc] initWithFrame:CGRectMake(0, top, self.frame.size.width, self.frame.size.height - top)];
        [_netList setTag:100];
    }
    return _netList;
}

- (PDLogList *)logList {
    if (!_logList) {
        _logList = [[PDLogList alloc] initWithFrame:self.netList.frame];
        [_logList setHidden:YES];
        [_logList setTag:101];
    }
    return _logList;
}

- (UIButton *)uploadButton {
    if (!_uploadButton) {
        _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _uploadButton.frame = CGRectMake(PDScreenWidth() - 60 - 10, 10, 60, self.segControl.frame.size.height);
        _uploadButton.layer.cornerRadius = 5;
        _uploadButton.backgroundColor = self.segControl.backgroundColor;
        _uploadButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_uploadButton setTitle:@"upload" forState:UIControlStateNormal];
        [_uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_uploadButton addTarget:self action:@selector(uploadAction) forControlEvents:UIControlEventTouchUpInside];
        _uploadButton.hidden = YES;
    }
    return _uploadButton;
}

@end

@interface PDNetList ()
@property (nonatomic, strong) NSArray *currentLogs;
@property (nonatomic, strong) NSTimer *timer;
@end

// 网络列表
@implementation PDNetList

- (void)dealloc {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self addSubview:self.cleanButton];
        [self.tableView setFrame:self.bounds];
        [self.cleanButton setFrame:CGRectMake(0, self.frame.size.height - 34, self.frame.size.width, 34)];
        [[PDRequestManager sharedInstance] handleRequest:^(NSArray<PDRequestModel *> * _Nonnull logs) {
            self.logs = [logs copy];
        }];
        [self reloadManager];
    }
    return self;
}

- (void)reloadManager {
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.currentLogs != weakSelf.logs) {
            weakSelf.currentLogs = weakSelf.logs;
            if ([NSThread isMainThread]) {
                [weakSelf.tableView reloadData];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
        }
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentLogs.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PDDebugAssistantNetCell *cell = [tableView dequeueReusableCellWithIdentifier:kPDBaseCellID];
    if (!cell) {
        cell = [[PDDebugAssistantNetCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPDBaseCellID];
        [cell setSepLineInset:UIEdgeInsetsZero];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setIndexPath:indexPath];
    [cell setAssistantDelegate:self];
    [cell fillData:[self.currentLogs objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AXDebugAssistantCellDelegate
- (void)tapCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *desc = [[self.currentLogs objectAtIndex:indexPath.row] debugDescription];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PDUITools sendCUrlToChat:desc];
    }];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否上传cURL到飞书测试群，仅Debug有效" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [[PDUITools getCurrentTopVC] presentViewController:alert animated:YES completion:nil];
}

- (void)doubleTapCellAtIndexPath:(NSIndexPath *)indexPath {
    PDRequestModel *model = [self.currentLogs objectAtIndex:indexPath.row];
    [PDFullScreenTextViewer showData:model];
}

#pragma mark - Methods

- (void)onClean {
    [[PDRequestManager sharedInstance] clearAllRequests];
}

#pragma mark - Getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
    }
    return _tableView;
}

- (UIButton *)cleanButton {
    if (!_cleanButton) {
        _cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanButton setBackgroundColor:[PDUITools colorWithHex:0xF4F4F4 alpha:1.0]];
        [_cleanButton setTitle:@"Clean" forState:UIControlStateNormal];
        [_cleanButton setTitleColor:[PDUITools colorWithHex:0x363636 alpha:1.0] forState:UIControlStateNormal];
        [_cleanButton addTarget:self action:@selector(onClean) forControlEvents:UIControlEventTouchUpInside];
        [_cleanButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _cleanButton;
}

@end

@interface PDLogList ()
@property (nonatomic, strong) NSArray *currentLogs;
@property (nonatomic, strong) NSTimer *timer;
@end

// 日志列表
@implementation PDLogList

- (void)dealloc {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self addSubview:self.cleanButton];
        [self.tableView setFrame:self.bounds];
        [self.cleanButton setFrame:CGRectMake(0, self.frame.size.height - 34, self.frame.size.width, 34)];
        PDLogManager.shared.logManagerRecord = ^(NSArray * _Nonnull logs) {
            self.logs = [logs copy];
        };
        
        [self reloadManager];
    }
    return self;
}

- (void)reloadManager {
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.currentLogs != weakSelf.logs) {
            weakSelf.currentLogs = weakSelf.logs;
            if ([NSThread isMainThread]) {
                [weakSelf.tableView reloadData];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
        }
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentLogs.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PDDebugAssistantCell *cell = [tableView dequeueReusableCellWithIdentifier:kPDBaseCellID];
    if (!cell) {
        cell = [[PDDebugAssistantCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPDBaseCellID];
        [cell.textLabel setFont:[UIFont systemFontOfSize:10]];
        [cell.textLabel setNumberOfLines:5];
    }
    
    [cell setIndexPath:indexPath];
    [cell setAssistantDelegate:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *log = [self.currentLogs objectAtIndex:indexPath.row];
    [cell.textLabel setText:log];
    if ([log containsString:@"[ERROR]"] || [log containsString:@"[WARN]"]) {
        [cell.textLabel setTextColor:[PDUITools colorWithHex:0xFF5D00 alpha:1.0f]];
    } else {
        [cell.textLabel setTextColor:[PDUITools colorWithHex:0x363636 alpha:1.0f]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AXDebugAssistantCellDelegate
- (void)tapCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *desc = [self.currentLogs objectAtIndex:indexPath.row];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PDUITools sendLogToChat:desc];
    }];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否上传当前日志到飞书测试群，仅Debug有效" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [[PDUITools getCurrentTopVC] presentViewController:alert animated:YES completion:nil];
}

- (void)doubleTapCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *desc = [self.currentLogs objectAtIndex:indexPath.row];
    [PDFullScreenTextViewer show:desc];
}

#pragma mark - Methods
- (void)onClean {
    [[PDLogManager shared] clearLogs];
}

#pragma mark - Getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
    }
    return _tableView;
}

- (UIButton *)cleanButton {
    if (!_cleanButton) {
        _cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanButton setBackgroundColor:[PDUITools colorWithHex:0xF4F4F4 alpha:1.0f]];
        [_cleanButton setTitle:@"Clean" forState:UIControlStateNormal];
        [_cleanButton setTitleColor:[PDUITools colorWithHex:0x363636 alpha:1.0f] forState:UIControlStateNormal];
        [_cleanButton addTarget:self action:@selector(onClean) forControlEvents:UIControlEventTouchUpInside];
        [_cleanButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _cleanButton;
}

@end


@implementation PDDebugAssistantCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addGestureRecognizer:self.tapGest];
        [self addGestureRecognizer:self.doubleTapGest];
        [self addGestureRecognizer:self.pressGest];
        [self.tapGest requireGestureRecognizerToFail:self.doubleTapGest];
    }
    return self;
}

#pragma mark - Methods
- (void)onTapGest:(UITapGestureRecognizer *)gest {
    if (self.assistantDelegate && [self.assistantDelegate respondsToSelector:@selector(tapCellAtIndexPath:)]) {
        [self.assistantDelegate tapCellAtIndexPath:self.indexPath];
    }
}

- (void)onDoubleTapGest:(UITapGestureRecognizer *)gest {
    if (self.assistantDelegate && [self.assistantDelegate respondsToSelector:@selector(doubleTapCellAtIndexPath:)]) {
        [self.assistantDelegate doubleTapCellAtIndexPath:self.indexPath];
    }
}

- (void)onLongPressGest:(UILongPressGestureRecognizer *)gest {
    if (gest.state == UIGestureRecognizerStateBegan) {
        if (self.assistantDelegate && [self.assistantDelegate respondsToSelector:@selector(longPressCellAtIndexPath:)]) {
            [self.assistantDelegate longPressCellAtIndexPath:self.indexPath];
        }
    }
}

#pragma mark - Getters
- (UITapGestureRecognizer *)tapGest {
    if (!_tapGest) {
        _tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGest:)];
    }
    return _tapGest;
}

- (UITapGestureRecognizer *)doubleTapGest {
    if (!_doubleTapGest) {
        _doubleTapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTapGest:)];
        [_doubleTapGest setNumberOfTapsRequired:2];
    }
    return _doubleTapGest;
}

- (UILongPressGestureRecognizer *)pressGest {
    if (!_pressGest) {
        _pressGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGest:)];
    }
    return _pressGest;
}

@end

@implementation PDDebugAssistantNetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat width = 52;
        NSArray<UILabel *> *labels = @[self.methodLabel, self.statusLabel, self.timeLabel];
        [labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTextAlignment:NSTextAlignmentCenter];
            [self.contentView addSubview:obj];
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(width);
                make.top.bottom.mas_equalTo(0);
                make.right.mas_equalTo(-((labels.count - 1 - idx) * width));
            }];
            UIView *sepLine = [[UIView alloc] init];
            sepLine.backgroundColor = [PDUITools colorWithHex:0xF8F8F8 alpha:1.0f];
            [self.contentView addSubview:sepLine];
            [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(1);
                make.left.top.bottom.mas_equalTo(obj);
            }];
        }];

        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
            make.right.mas_equalTo(-(labels.count * width + 16));
        }];
    }
    return self;
}

- (void)fillData:(PDRequestModel *)model {
    [self.nameLabel setText:model.request.URL.absoluteString];
    [self.methodLabel setText:model.request.HTTPMethod];
    [self.statusLabel setText:model.formatCode];
    [self.timeLabel setText:model.formatTime];
    
    if (model.isAvailable) {
        [self.nameLabel setTextColor:[PDUITools colorWithHex:0x363636 alpha:1.0f]];
        [self.methodLabel setTextColor:[PDUITools colorWithHex:0x363636 alpha:1.0f]];
        [self.statusLabel setTextColor:[PDUITools colorWithHex:0x363636 alpha:1.0f]];
        [self.timeLabel setTextColor:[PDUITools colorWithHex:0x363636 alpha:1.0f]];
    } else {
        [self.nameLabel setTextColor:[UIColor systemRedColor]];
        [self.methodLabel setTextColor:[UIColor systemRedColor]];
        [self.statusLabel setTextColor:[UIColor systemRedColor]];
        [self.timeLabel setTextColor:[UIColor systemRedColor]];
    }
}

#pragma mark - Getters
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = [PDUITools colorWithHex:0x363636 alpha:1.0f];
        [_nameLabel setNumberOfLines:0];
    }
    return _nameLabel;
}

- (UILabel *)methodLabel {
    if (!_methodLabel) {
        _methodLabel = [[UILabel alloc] init];
        _methodLabel.font = [UIFont systemFontOfSize:12];
        _methodLabel.textColor = [PDUITools colorWithHex:0x363636 alpha:1.0f];
    }
    return _methodLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textColor = [PDUITools colorWithHex:0x363636 alpha:1.0f];
    }
    return _statusLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [PDUITools colorWithHex:0x363636 alpha:1.0f];
    }
    return _timeLabel;
}

@end

@implementation PDFullScreenTextViewer

+ (void)show:(NSString *)text {
    PDFullScreenTextViewer *viewer = [PDFullScreenTextViewer new];
    [viewer setAlpha:0];
    [viewer setText:text];
    [[PDUITools getRootWindow] addSubview:viewer];
    [UIView animateWithDuration:0.25 animations:^{
        [viewer setAlpha:1];
    }];
}

+ (void)showData:(PDRequestModel *)model {
    PDFullScreenTextViewer *viewer = [PDFullScreenTextViewer new];
    [viewer setAlpha:0];
    [viewer setHttpRequest:model];
    [[PDUITools getRootWindow] addSubview:viewer];
    [UIView animateWithDuration:0.25 animations:^{
        [viewer setAlpha:1];
    }];
}

+ (void)dismiss {
    [[PDUITools getRootWindow].subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PDFullScreenTextViewer class]]) {
            [(PDFullScreenTextViewer *)obj onDismiss];
        }
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:UIScreen.mainScreen.bounds];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)setText:(NSString *)text {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineSpacing:8];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, text.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, text.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[PDUITools colorWithHex:0x363636 alpha:1.0f] range:NSMakeRange(0, text.length)];
    [self.textView setAttributedText:attrStr];
}

- (void)setHttpRequest:(PDRequestModel *)model {
    
    NSMutableString *general = [NSMutableString new];
    [general appendFormat:@"URL: %@\n", model.request.URL.absoluteString];
    [general appendFormat:@"Method: %@\n", model.request.HTTPMethod];
    
    __block NSMutableString *headers = [NSMutableString new];
    [model.request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
      [headers appendFormat:@"%@: %@\n", key, val];
    }];
    
    NSMutableString *body = [NSMutableString new];
    if (model.request.HTTPBody) {
        [body appendFormat:@"%@\n", [[NSString alloc] initWithData:model.request.HTTPBody encoding:NSUTF8StringEncoding]];
    } else if (model.request.HTTPBodyStream) {
        uint8_t sub[1024] = {0};
        NSInputStream *inputStream = model.request.HTTPBodyStream;
        NSMutableData *bodyData = [[NSMutableData alloc] init];
        [inputStream open];
        while ([inputStream hasBytesAvailable]) {
            NSInteger len = [inputStream read:sub maxLength:1024];
            if (len > 0 && inputStream.streamError == nil) {
                [bodyData appendBytes:(void *)sub length:len];
            } else {
                break;
            }
        }
        
        id jsonDecoded = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
        if (jsonDecoded) {
            [body appendFormat:@"%@\n", [jsonDecoded description]];
        } else {
            [body appendFormat:@"%@\n", [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]];
        }
    }
    
    NSString *responseDesc = @"";
    if (model.error) {
        responseDesc = model.error.description;
    } else if (model.data) {
        id jsonDecoded = [NSJSONSerialization JSONObjectWithData:model.data options:kNilOptions error:nil];
        if (jsonDecoded) {
            responseDesc = [jsonDecoded description];
        } else {
            responseDesc = [[NSString alloc] initWithData:model.data encoding:NSUTF8StringEncoding];
        }
    }
    
    if (!responseDesc) {
        responseDesc = @"";
    }
    
    NSString *requestTitle = @"\nRequest\n";
    NSString *generalTitle = @"\nGeneral\n";
    NSString *headerTitle = @"\nHeaders\n";
    NSString *bodyTitle = @"\nBody\n";
    NSString *responseTitle = @"\nResponse\n";
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineSpacing:5];
    NSString *text;
    if (body.length) {
        text = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@\n\n\n", requestTitle, generalTitle, general, headerTitle, headers, bodyTitle, body, responseTitle, responseDesc];
    } else {
        text = [NSString stringWithFormat:@"%@%@%@%@%@%@%@\n\n\n", requestTitle, generalTitle, general, headerTitle, headers, responseTitle, responseDesc];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attrStr addAttributes:@{NSParagraphStyleAttributeName: paragraph} range:NSMakeRange(0, attrStr.length)];
    
    NSUInteger loc = 0;
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(loc, requestTitle.length)];
    loc += requestTitle.length;
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(loc, generalTitle.length)];
    loc += generalTitle.length;
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(loc, general.length)];
    loc += general.length;
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(loc, headerTitle.length)];
    loc += headerTitle.length;
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(loc, headers.length)];
    loc += headers.length;
    if (body.length) {
        [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(loc, bodyTitle.length)];
        loc += bodyTitle.length;
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(loc, body.length)];
        loc += body.length;
    }
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(loc, responseTitle.length)];
    loc += responseTitle.length;
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(loc, responseDesc.length)];
    
    [self.textView setAttributedText:attrStr];
}

#pragma mark - Events
- (void)onDismiss {
    [UIView animateWithDuration:0.25 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Getters
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.backgroundColor = [UIColor whiteColor];
        [_textView setEditable:NO];
        [_textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismiss)]];
        [_textView setContentInset:UIEdgeInsetsMake(PDStatusHeight(), 20, PDSafeAreaBottom(), 20)];
    }
    return _textView;
}

@end
