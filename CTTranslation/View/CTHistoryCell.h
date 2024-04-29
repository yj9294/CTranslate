//
//  CTHistoryCell.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/18.
//

#import <UIKit/UIKit.h>
#import "CTHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTHistoryCell : UITableViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *sourceLangLabel;
@property (nonatomic, strong) UILabel *sourceTextLabel;
@property (nonatomic, strong) UILabel *targetLangLabel;
@property (nonatomic, strong) UILabel *targetTextLabel;
@property (nonatomic, strong) UIButton *boxButton;
@property (nonatomic, strong) CTHistoryModel *model;
@property (nonatomic, copy) void(^longCell)(void);

@end

NS_ASSUME_NONNULL_END
