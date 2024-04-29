//
//  CTHomeHeaderView.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTHomeHeaderView.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"

@implementation CTHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        UIView *diaView = [self viewWithType:CTHomeSelectTypeDia text:@"Dialogue" logo:@"home_dialogue" backgroud:@"home_dialogue_bg"];
        UIView *textView = [self viewWithType:CTHomeSelectTypeText text:@"Text" logo:@"home_text" backgroud:@"home_text_bg"];
        UIView *voiceView = [self viewWithType:CTHomeSelectTypeVoice text:@"Voice" logo:@"home_voice" backgroud:@"home_voice_bg"];
        UIView *cameraView = [self viewWithType:CTHomeSelectTypeCamera text:@"Camera" logo:@"home_camera" backgroud:@"home_camera_bg"];
        UIView *usefulView = [self viewWithType:CTHomeSelectTypeUseful text:@"Useful Expressions" logo:@"home_useful" backgroud:@"home_useful_bg"];
        
        [self addSubview:diaView];
        [self addSubview:textView];
        [self addSubview:voiceView];
        [self addSubview:cameraView];
        [self addSubview:usefulView];
        
        [diaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.height.mas_equalTo(200);
            make.width.mas_equalTo(CTScreenWidth() - 227);
        }];
        
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(187);
            make.height.mas_equalTo(60);
        }];
        
        [voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(textView.mas_bottom).offset(10);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(187);
            make.height.mas_equalTo(60);
        }];
        
        [cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(voiceView.mas_bottom).offset(10);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(187);
            make.height.mas_equalTo(60);
        }];
        
        [usefulView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(diaView.mas_bottom).offset(15);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(CTScreenWidth() - 30);
            make.height.mas_equalTo(80);
        }];
        
        UIView *tipView = [[UIView alloc] init];
        tipView.backgroundColor = [UIColor hexColor:@"#D56F5E"];
        tipView.layer.cornerRadius = 2;
        tipView.layer.masksToBounds = YES;
        
        UILabel *label = [UILabel lbText:@"Recommend" font:[UIFont pFont:15] color:[UIColor whiteColor]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"More" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont pFont:12];
        [button tColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6]];
        [button nImage:[UIImage imageNamed:@"home_arrow"] hImage:nil];
        [button layoutWithType:LXButtonLayoutTypeImageRight subMargin:5];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:tipView];
        [self addSubview:label];
        [self addSubview:button];
        
        [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(usefulView.mas_bottom).offset(19);
            make.left.mas_equalTo(15);
            make.width.mas_equalTo(4);
            make.height.mas_equalTo(14);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(tipView);
            make.left.mas_equalTo(24);
        }];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(tipView);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(80);
        }];
    }
    return self;
}

- (UIView *)viewWithType:(CTHomeSelectType)type text:(NSString *)text logo:(NSString *)logo backgroud:(NSString *)backgroud {
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroud]];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.layer.cornerRadius = 5;
    bgImageView.layer.masksToBounds = YES;
    bgImageView.userInteractionEnabled = YES;
    bgImageView.tag = 500 + type;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [bgImageView addGestureRecognizer:tap];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logo]];
    [bgImageView addSubview:logoImageView];
    UILabel *textLabel = [UILabel lbText:text font:[UIFont pFont:16] color:[UIColor whiteColor]];
    [bgImageView addSubview:textLabel];
    
    if (type == CTHomeSelectTypeDia) {
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(165);
            make.height.mas_equalTo(125);
        }];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(30);
            make.centerX.mas_equalTo(0);
        }];
    } else if (type == CTHomeSelectTypeUseful) {
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_equalTo(0);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
        }];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.centerY.mas_equalTo(0);
        }];
    } else {
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_equalTo(0);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(60);
        }];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.centerY.mas_equalTo(0);
        }];
    }
    return bgImageView;
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CTHomeSelectType type =  view.tag - 500;
    if (self.selectItem) self.selectItem(type);
}

- (void)buttonAction {
    if (self.selectItem) self.selectItem(CTHomeSelectTypeMore);
}

@end
