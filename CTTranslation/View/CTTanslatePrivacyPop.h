//
//  CTTanslatePrivacyPop.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/5.
//

#import <UIKit/UIKit.h>
#import <YYText/YYLabel.h>
#import "CTPop.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTTanslatePrivacyPop : CTPop

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) YYLabel *contentLabel;
@property (nonatomic, strong) UIButton *button;

- (void)showWithComplete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
