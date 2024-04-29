//
//  CTDialogueCell.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/15.
//

#import <UIKit/UIKit.h>
#import "CTDialogueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTDialogueCell : UITableViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, strong) UIView *segView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) CTDialogueModel *model;
@property (nonatomic, strong) void(^playVoice)(CTDialogueModel *model);

@end

@interface CTDialogueLeftCell : CTDialogueCell

@end

@interface CTDialogueRightCell : CTDialogueCell

@end

NS_ASSUME_NONNULL_END
