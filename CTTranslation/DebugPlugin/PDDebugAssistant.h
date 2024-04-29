//
//  PDDebugAssistant.h
//  SunUIKit
//
//  Created by cttranslation on 2020/7/30.
//  调试控制面板，仅Debug有效

#import <Foundation/Foundation.h>
#import "PDURLProtocol.h"
#import <UIKit/UIKit.h>
#import "PDBaseCell.h"

@class PDLogList;
@class PDDebugAssistantCell;

NS_ASSUME_NONNULL_BEGIN

@protocol PDDebugAssistantCellDelegate <NSObject>

@optional
- (void)tapCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)doubleTapCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)longPressCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PDDebugAssistant : NSObject

// 启动Debug
+ (void)fire;
+ (void)invalidate;

@end

@interface PDDebugWindow : UIWindow

- (void)show;
- (void)dismiss;

@end

@interface PDDebugPanel : UIView

@end

// 网络列表
@interface PDNetList : UIView<UITableViewDelegate, UITableViewDataSource, PDDebugAssistantCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cleanButton;
@property (nonatomic, strong) NSArray<PDRequestModel *> *logs;

@end

// 日志列表
@interface PDLogList : UIView<UITableViewDelegate, UITableViewDataSource, PDDebugAssistantCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cleanButton;
@property (nonatomic, strong) NSArray *logs;

@end

// 双击Cell
@interface PDDebugAssistantCell : PDBaseCell

@property (nonatomic, weak) id<PDDebugAssistantCellDelegate> assistantDelegate;
@property (nonatomic, strong) UITapGestureRecognizer *tapGest;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGest;
@property (nonatomic, strong) UILongPressGestureRecognizer *pressGest;

@end

@interface PDDebugAssistantNetCell : PDDebugAssistantCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *timeLabel;

- (void)fillData:(PDRequestModel *)model;

@end

// 全屏信息查看视图
@interface PDFullScreenTextViewer : UIView

@property (nonatomic, strong) UITextView *textView;

+ (void)show:(NSString *)text;
+ (void)showData:(PDRequestModel *)model;
+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
