//
//  CTTextView.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTTextView : UITextView

- (void)configPlaceholder:(NSString *)placeholder font:(UIFont *)font textColor:(UIColor *)color;
- (void)didValueChanged;
@end

NS_ASSUME_NONNULL_END
