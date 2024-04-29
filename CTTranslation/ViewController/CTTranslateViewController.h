//
//  CTTranslateViewController.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import <UIKit/UIKit.h>
#import "CTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTTranslateType) {
    CTTranslateTypeText,
    CTTranslateTypeVoice,
    CTTranslateTypeCamera,
};

@interface CTTranslateViewController : CTBaseViewController

@property (nonatomic, assign) CTTranslateType translateType;
@property (nonatomic, strong) NSString *translateText;

- (id)initWithType:(CTTranslateType)type;

@end

NS_ASSUME_NONNULL_END
