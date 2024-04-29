//
//  CTChangeLangugeView.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/14.
//

#import <UIKit/UIKit.h>
#import "CTTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

#define SOURCE_LANGUGE @"sourceLanguge"
#define TARGET_LANGUGE @"targetLanguge"

@interface CTChangeLangugeView : UIView

@property (nonatomic, strong) CTTranslateModel *sourceModel;
@property (nonatomic, strong) CTTranslateModel *targetModel;
@property (nonatomic, copy) void(^sourceChange)(NSString *text);
@property (nonatomic, copy) void(^targetChange)(NSString *text);

- (void)syncLanguage;

@end

NS_ASSUME_NONNULL_END
