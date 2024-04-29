//
//  CTTextView.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/14.
//

#import "CTTextView.h"
#import "UIView+CT.h"

@interface CTTextView ()

@property (nonatomic, strong) UITextView *holderView;

@end

@implementation CTTextView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(nullable NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeyDefault;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.secureTextEntry = NO;
        textContainer.lineBreakMode = NSLineBreakByCharWrapping;
        self.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.font = [UIFont fontWithSize:17];
        self.textColor = [UIColor whiteColor];
        self.textContainerInset = UIEdgeInsetsMake(15, 15, 40, 15);
        self.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    }
    return self;
}

- (void)configPlaceholder:(NSString *)placeholder font:(UIFont *)font textColor:(UIColor *)color {
    self.holderView = [[UITextView alloc] init];
    self.holderView.text = placeholder;
    if (font) {
        self.holderView.font = font;
    }
    if (color) {
        self.holderView.textColor = color;
    }
    self.holderView.userInteractionEnabled = NO;
    self.holderView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self insertSubview:_holderView atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChangeNoto:) name:UITextViewTextDidChangeNotification object:self];
    [self didValueChanged];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self didValueChanged];
    if (self.holderView && !self.holderView.hidden) {
        self.holderView.textContainerInset = self.textContainerInset;
        self.holderView.textContainer.exclusionPaths = self.textContainer.exclusionPaths;
        self.holderView.textAlignment = self.textAlignment;
        self.holderView.frame = self.bounds;
    }
}

- (void)valueChangeNoto:(NSNotification *)notify {
    if (self == notify.object) {
        [self didValueChanged];
    }
}

- (void)didValueChanged {
    self.holderView.hidden = self.text.length > 0 ? YES : NO;
}

@end
