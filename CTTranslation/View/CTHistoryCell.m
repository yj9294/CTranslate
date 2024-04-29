//
//  CTHistoryCell.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/18.
//

#import "CTHistoryCell.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"

@implementation CTHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor hexColor:@"#12263A"];
        self.bgView = [[UIView alloc] init];
        self.bgView.layer.cornerRadius = 10;
        self.bgView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        [self.contentView addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        self.sourceLangLabel = [UILabel lbText:@"" font:[UIFont pFont:14] color:[UIColor hexColor:@"#D56F5E"]];
        [self.bgView addSubview:self.sourceLangLabel];
        [self.sourceLangLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(15);
        }];
        
        self.sourceTextLabel = [UILabel lbText:@"" font:[UIFont pFont:13] color:[UIColor whiteColor]];
        self.sourceTextLabel.numberOfLines = 0;
        [self.bgView addSubview:self.sourceTextLabel];
        [self.sourceTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sourceLangLabel.mas_bottom).offset(5);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        [self.bgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sourceTextLabel.mas_bottom).offset(5);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(1);
        }];
        
        self.targetLangLabel = [UILabel lbText:@"" font:[UIFont pFont:14] color:[UIColor hexColor:@"#D56F5E"]];
        [self.bgView addSubview:self.targetLangLabel];
        [self.targetLangLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom).offset(5);
            make.left.mas_equalTo(15);
        }];
        
        self.targetTextLabel = [UILabel lbText:@"" font:[UIFont pFont:13] color:[UIColor whiteColor]];
        self.targetTextLabel.numberOfLines = 0;
        [self.bgView addSubview:self.targetTextLabel];
        [self.targetTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.targetLangLabel.mas_bottom).offset(5);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.bottom.mas_offset(-15);
        }];
        
        self.boxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.boxButton bgImage:[UIImage imageNamed:@"history_select_normal"]];
        [self.boxButton addTarget:self action:@selector(selectAction) forControlEvents:UIControlEventTouchUpInside];
        [self.boxButton setEnlargeEdge:10];
        self.boxButton.hidden = YES;
        [self.bgView addSubview:self.boxButton];
        [self.boxButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.right.mas_equalTo(-16);
            make.height.width.mas_equalTo(20);
        }];
        
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction)];
        [self addGestureRecognizer:longTap];
    }
    return self;
}

- (void)longAction {
    if (self.longCell) self.longCell();
}

- (void)selectAction {
    self.model.isSelect = !self.model.isSelect;
    [self.boxButton bgImage:[UIImage imageNamed:self.model.isSelect ? @"history_select_selected" : @"history_select_normal"]];
}

- (void)setModel:(CTHistoryModel *)model {
    _model = model;
    self.sourceLangLabel.text = model.sourceLang;
    self.sourceTextLabel.text = model.sourceText;
    self.targetLangLabel.text = model.targetLang;
    self.targetTextLabel.text = model.targetText;
    self.boxButton.hidden = !model.isShowBox;
    [self.boxButton bgImage:[UIImage imageNamed:self.model.isSelect ? @"history_select_selected" : @"history_select_normal"]];
}

@end
