//
//  CTChooseLanguageViewController.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/14.
//

#import "CTBaseViewController.h"
#import "CTTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTChooseLanguageViewController : CTBaseViewController

@property (nonatomic, assign) BOOL isHiddenBackButton;
@property (nonatomic, copy) void(^selectModel)(CTTranslateModel *model);

@end

NS_ASSUME_NONNULL_END
