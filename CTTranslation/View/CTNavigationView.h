//
//  CTNavigationView.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTNavigationView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *leftButton;

- (void)navBack;

@end

NS_ASSUME_NONNULL_END
