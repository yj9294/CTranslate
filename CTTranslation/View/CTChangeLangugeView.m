//
//  CTChangeLangugeView.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/14.
//

#import "CTChangeLangugeView.h"
#import "CTChooseLanguageViewController.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"

@interface CTChangeLangugeView ()

@property (nonatomic, strong) UIButton *sourceButton;
@property (nonatomic, strong) UIButton *targetButton;
@property (nonatomic, strong) UIButton *changeButton;

@end

@implementation CTChangeLangugeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        self.sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sourceButton setTitle:@"" forState:UIControlStateNormal];
        [self.sourceButton tColor:[UIColor whiteColor]];
        self.sourceButton.titleLabel.font = [UIFont fontWithSize:14];
        [self.sourceButton bgColor:[UIColor hexColor:@"#5D6B83"]];
        self.sourceButton.layer.cornerRadius = 10;
        self.sourceButton.layer.masksToBounds = YES;
        [self.sourceButton nImage:[UIImage imageNamed:@"change_lang_arrow"] hImage:nil];
        [self.sourceButton layoutWithType:LXButtonLayoutTypeImageRight subMargin:12];
        [self.sourceButton addTarget:self action:@selector(sourceAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sourceButton];
        [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
        }];
        
        self.changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.changeButton nImage:[UIImage imageNamed:@"change_lang_change"] hImage:nil];
        [self.changeButton addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.changeButton];
        [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.sourceButton.mas_right).offset(5);
        }];
        
        self.targetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.targetButton setTitle:@"" forState:UIControlStateNormal];
        [self.targetButton tColor:[UIColor whiteColor]];
        self.targetButton.titleLabel.font = [UIFont fontWithSize:14];
        [self.targetButton bgColor:[UIColor hexColor:@"#5D6B83"]];
        self.targetButton.layer.cornerRadius = 10;
        self.targetButton.layer.masksToBounds = YES;
        [self.targetButton nImage:[UIImage imageNamed:@"change_lang_arrow"] hImage:nil];
        [self.targetButton layoutWithType:LXButtonLayoutTypeImageRight subMargin:12];
        [self.targetButton addTarget:self action:@selector(targetAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.targetButton];
        [self.targetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-15);
            make.left.equalTo(self.changeButton.mas_right).offset(5);
        }];
        
        [self languageUpdate];
    }
    return self;
}

- (void)syncLanguage {
    CTLanguageType sourceType = [[[NSUserDefaults standardUserDefaults] objectForKey:SOURCE_LANGUGE] integerValue];
    CTLanguageType targetType = [[[NSUserDefaults standardUserDefaults] objectForKey:TARGET_LANGUGE] integerValue];
    self.sourceModel = [CTTranslateModel modelWithType:sourceType];
    self.targetModel = [CTTranslateModel modelWithType:targetType];
    
    [self.sourceButton setTitle:self.sourceModel.name forState:UIControlStateNormal];
    [self.targetButton setTitle:self.targetModel.name forState:UIControlStateNormal];
}

- (void)languageUpdate {
    [self.sourceButton setTitle:self.sourceModel.name forState:UIControlStateNormal];
    [self.targetButton setTitle:self.targetModel.name forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.sourceModel.type) forKey:SOURCE_LANGUGE];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.targetModel.type) forKey:TARGET_LANGUGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sourceAction {
    CTChooseLanguageViewController *vc = [[CTChooseLanguageViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.selectModel = ^(CTTranslateModel * _Nonnull model) {
        weakSelf.sourceModel = model;
        [weakSelf languageUpdate];
        if (weakSelf.sourceChange) weakSelf.sourceChange(model.identifier);
    };
    [self.navController pushViewController:vc animated:YES];
}

- (void)targetAction {
    CTChooseLanguageViewController *vc = [[CTChooseLanguageViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.selectModel = ^(CTTranslateModel * _Nonnull model) {
        weakSelf.targetModel = model;
        [weakSelf languageUpdate];
        if (weakSelf.targetChange) weakSelf.targetChange(model.identifier);
    };
    [self.navController pushViewController:vc animated:YES];
}

- (void)changeAction {
    CTTranslateModel *model = self.sourceModel;
    self.sourceModel = self.targetModel;
    self.targetModel = model;
    [self languageUpdate];
    if (self.sourceChange) self.sourceChange(self.sourceModel.identifier);
    if (self.targetChange) self.targetChange(self.targetModel.identifier);
}

- (CTTranslateModel *)sourceModel {
    if (!_sourceModel) {
        CTLanguageType type = CTLanguageTypeEnglish;
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:SOURCE_LANGUGE];
        if (obj) {
            type = [obj integerValue];
        }
        _sourceModel = [CTTranslateModel modelWithType:type];
    }
    return _sourceModel;
}

- (CTTranslateModel *)targetModel {
    if (!_targetModel) {
        CTLanguageType type = CTLanguageTypeChineseSimplified;
        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:TARGET_LANGUGE];
        if (obj) {
            type = [obj integerValue];
        }
        _targetModel = [CTTranslateModel modelWithType:type];
    }
    return _targetModel;
}

@end
