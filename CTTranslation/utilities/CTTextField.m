//
//  CTTextField.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/26.
//

#import "CTTextField.h"
#import "UIView+CT.h"

@interface CTTextField ()

@end

@implementation CTTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __textField_setupUI];
    }
    return self;
}

- (void)__textField_setupUI {
//    self.currentLength = 0;
    
//        self.delegate = self;
    self.backgroundColor = [UIColor hexColor:@"#292E34"];
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDone;
    self.borderStyle = UITextBorderStyleNone;
    
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont pFont:14];
    self.textRectInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    self.layer.cornerRadius = 20;
    
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

//- (void)setPlaceholderText:(NSString *)placeholder {
//    [self setPlaceholderText:placeholder font:[UIFont pFont:14] color:[[UIColor whiteColor] colorWithAlphaComponent:0.6]];
//}

- (void)setPlaceholderText:(NSString *)placeholder font:(UIFont *)font color:(UIColor *)color {
    if (placeholder) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:placeholder];
        if (font) {
            [attr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, placeholder.length)];
        }
        if (color) {
            [attr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, placeholder.length)];
        }
        [self setAttributedPlaceholder:attr];
    }
}

#pragma mark - Methods
- (void)textFieldDidChange:(UITextField *)textField {
    if (![textField isEqual:self]) {
        return;
    }
    
//    if (self.maxLength > 0) {
//        NSString *markedText = [textField textInRange:[textField markedTextRange]];
//        if (markedText.length > 0) {
//            return;
//        }
//        
//        if (textField.text.length >= self.maxLength) {
//            textField.text = [textField.text substringToIndex:self.maxLength];
//        }
//    }
//    
//    if (self.maxValue > 0) {
//        if ([textField.text floatValue] > self.maxValue) {
//            textField.text = [textField.text substringToIndex:textField.text.length - 1];
//        }
//        
//        if ([textField.text integerValue] == self.maxValue && [textField.text hasSuffix:@"."]) {
//            textField.text = [textField.text substringToIndex:textField.text.length - 1];
//        }
//    }
    
    if (textField.keyboardType == UIKeyboardTypeNumberPad || textField.keyboardType == UIKeyboardTypeDecimalPad) {
        if ([textField.text hasPrefix:@"."]) {
            textField.text = @"0.";
        }
        
        if ([textField.text hasPrefix:@"0"] && ![textField.text containsString:@"."] && textField.text.length > 1) {
            textField.text = [textField.text substringFromIndex:1];
        }
    }
    
//    self.currentLength = self.text.length;
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    
//    if (textField.keyboardType != UIKeyboardTypeDecimalPad) {
//        return YES;
//    }
//    
//    // 正整数长度
//    NSInteger positiveLength = 9;
//    if (self.maxValue > 0) {
//        positiveLength = [NSString stringWithFormat:@"%@", @(self.maxValue)].length;
//    }
//    
//    if (![string isEqualToString:@""] && [textField isEqual:self]) {
//        NSInteger dotLocation = [textField.text rangeOfString:@"."].location;
//        if (dotLocation == NSNotFound && range.location != 0) {
//            if (range.location >= positiveLength) {
//                if ([string isEqualToString:@"."] && range.location == positiveLength) {
//                    return YES;
//                }
//                return NO;
//            }
//        }
//        
//        if (dotLocation != NSNotFound && ([string isEqualToString:@"."] || range.location > dotLocation + 2)) {
//            return NO;
//        }
//        
//        if (textField.text.length > positiveLength + 2) {
//            return NO;
//        }
//    }
//    return YES;
//}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    return [self adaptRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self adaptRectForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self adaptRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    rect.origin.x += self.textRectInsets.left;
    return rect;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
    rect.origin.x -= 10;
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super rightViewRectForBounds:bounds];
    rect.origin.x -= self.textRectInsets.right;
    return rect;
}


- (CGRect)adaptRectForBounds:(CGRect)bounds {
    CGRect rect = bounds;
    if (self.textRectInsets.left != 0 || self.textRectInsets.right != 0) {
        rect.origin.x += self.textRectInsets.left;
        rect.size.width = rect.size.width - self.textRectInsets.left - self.textRectInsets.right;
    }
    
    if (self.textRectInsets.top != 0) {
        rect.origin.y += self.textRectInsets.top;
    }
    return rect;
}

@end
