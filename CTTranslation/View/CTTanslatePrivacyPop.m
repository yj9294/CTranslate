//
//  CTTanslatePrivacyPop.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/5.
//

#import "CTTanslatePrivacyPop.h"
#import "UIView+CT.h"
#import "CTWebVC.h"
#import <YYText/NSAttributedString+YYText.h>

@interface CTTanslatePrivacyPop ()

@property (nonatomic, strong) void(^complete)(void);

@end

@implementation CTTanslatePrivacyPop

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor hexColor:@"#D9D9D9"];
        self.contentView.layer.cornerRadius = 10;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"policy_logo"]];
    [self.contentView addSubview:logoImageView];
    
    UILabel *titleLabel = [UILabel lbText:@"privacy" font:[UIFont fontWithSize:18 weight:UIFontWeightMedium] color:[UIColor hexColor:@"#333333"]];
    [self.contentView addSubview:titleLabel];
    
    NSString *message = @"    Thank you for using Co Translation, We attach great importance to the protection of user personal information. Please read and understand the 《Privacy Policy》 in detail. If you agreed to all the contents of the policy, please click \"Agree\"";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: [UIFont pFont:15], NSForegroundColorAttributeName: [UIColor hexColor:@"#999999"], NSParagraphStyleAttributeName: paragraphStyle}];
    
    [attribute yy_setTextHighlightRange:[[attribute string] rangeOfString:@"《Privacy Policy》"] color:[UIColor hexColor:@"#D56F5E"] backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        UIViewController *vc = [UIApplication sharedApplication].windows.firstObject.rootViewController;
        CTWebVC *webvc = [[CTWebVC alloc] initWithUrl:@"https://sites.google.com/view/co-translation"];
        [vc presentViewController:webvc animated:YES completion:nil];
    }];
    
    self.contentLabel = [[YYLabel alloc] init];
    self.contentLabel.textColor = [UIColor hexColor:@"#999999"];
    self.contentLabel.font = [UIFont pFont:15];
    self.contentLabel.preferredMaxLayoutWidth = CTScreenWidth() - 60;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.attributedText = attribute;
    [self.contentView addSubview:self.contentLabel];
   
    self.button = [UIButton btTitle:@"Agree"];
    [self.button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.button];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(65);
        make.centerX.mas_equalTo(0);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(0);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).offset(30);
        make.bottom.mas_equalTo(-30);
        make.width.mas_equalTo(235);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(46);
    }];
}

- (void)showWithComplete:(void(^)(void))complete {
    self.complete = complete;
    [self show];
}

- (void)action {
    if (self.complete) self.complete();
    [self dismiss];
}

@end
