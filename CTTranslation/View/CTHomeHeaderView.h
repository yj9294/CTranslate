//
//  CTHomeHeaderView.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTHomeSelectType) {
    CTHomeSelectTypeDia = 0,
    CTHomeSelectTypeText,
    CTHomeSelectTypeVoice,
    CTHomeSelectTypeCamera,
    CTHomeSelectTypeUseful,
    CTHomeSelectTypeMore,
    CTHomeSelectTypeHistory,
    CTHomeSelectTypeRecommandInfo,
};

@interface CTHomeHeaderView : UIView

@property (nonatomic, copy) void(^selectItem)(CTHomeSelectType type);

@end

NS_ASSUME_NONNULL_END
