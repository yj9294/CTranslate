//
//  CTTextField.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets textRectInsets;
//@property (nonatomic, assign) NSInteger currentLength;
//@property (nonatomic, assign) NSInteger maxLength;
//@property (nonatomic, assign) CGFloat maxValue;
//- (void)setPlaceholderText:(NSString *)placeholder;
- (void)setPlaceholderText:(NSString *)placeholder font:(UIFont *)font color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
