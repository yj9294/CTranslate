//
//  PDBaseCell.h
//  SunUIKit
//
//  Created by cttranslation on 2020/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kPDBaseCellID = @"kPDBaseCellID";
static NSString * const kPDBaseHeadID = @"kPDBaseHeadID";
static NSString * const kPDBaseFootID = @"kPDBaseFootID";

/// 这里的常量定义适用于单个List中有多个样式的Cell情况
static NSString * const kPDBaseCellID2 = @"kPDBaseCellID2";
static NSString * const kPDBaseCellID3 = @"kPDBaseCellID3";
static NSString * const kPDBaseCellID4 = @"kPDBaseCellID4";
static NSString * const kPDBaseCellID5 = @"kPDBaseCellID5";

@protocol PDBaseCellDelegate <NSObject>

@optional
// 用于子类单纯的选择动作
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
// 用于子类带有复选框的选择动作
- (void)didSelectionCellAtIndexPath:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected;

@end

@interface PDBaseCell : UITableViewCell

+ (NSString *)cellID;

/// 分割线
@property (nonatomic, strong) UIView *sepLine;

/// 是否显示分割线，默认显示
@property (nonatomic, assign) BOOL showSepLine;

/// 分割线颜色，默认vF8F
@property (nonatomic, strong) UIColor *sepLineColor;

/// 自定义分割线Padding，默认(25, 25)
@property (nonatomic, assign) UIEdgeInsets sepLineInset;

/// Cell 索引，用于自定义Cell点击时的代理
@property (nonatomic, strong) NSIndexPath *indexPath;

/// 用于子类计算索引等操作
@property (nonatomic, strong) UITableView *tableView;

/// 用于子类
@property (nonatomic, weak) id<PDBaseCellDelegate> baseDelegate;

/// 子类实现
+ (CGFloat)cellHeight;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
