//
//  CTDialogueCell.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/15.
//

#import "CTDialogueCell.h"
#import "UIView+CT.h"
#import "UIButton+CTL.h"

@implementation CTDialogueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor hexColor:@"#12263A"];
        self.bgView = [[UIView alloc] init];
        self.bgView.layer.cornerRadius = 10;
        self.bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.bgView];
        
        self.sourceLabel = [UILabel lbText:@"" font:[UIFont pFont:13] color:[UIColor whiteColor]];
        self.sourceLabel.numberOfLines = 0;
        [self.bgView addSubview:self.sourceLabel];
        [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_lessThanOrEqualTo(-10);
            make.top.mas_equalTo(10);
        }];
        
        self.segView = [[UIView alloc] init];
        [self.bgView addSubview:self.segView];
        [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sourceLabel.mas_bottom).offset(5);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(1);
        }];
        
        self.targetLabel = [UILabel lbText:@"" font:[UIFont pFont:13] color:[UIColor whiteColor]];
        self.targetLabel.numberOfLines = 0;
        [self.bgView addSubview:self.targetLabel];
        [self.targetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_lessThanOrEqualTo(-10);
            make.top.equalTo(self.segView.mas_bottom).offset(5);
            make.bottom.mas_equalTo(-10);
        }];
        
        self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.voiceButton bgImage:[UIImage imageNamed:@"dialogue_play"]];
        [self.voiceButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:5];
        [self.voiceButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.voiceButton];
    }
    return self;
}

- (void)setModel:(CTDialogueModel *)model {
    _model = model;
    self.sourceLabel.text = model.source;
    self.targetLabel.text = model.target;
    [self.voiceButton bgImage:[UIImage imageNamed:model.isPlay ? @"dialogue_pause" : @"dialogue_play"]];
}

- (void)playAction {
    if (self.playVoice) self.playVoice(self.model);
}

@end

@implementation CTDialogueLeftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bgView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        self.bgView.layer.maskedCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight;
        self.segView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_lessThanOrEqualTo(-60);
        }];
        
        [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.left.equalTo(self.bgView.mas_right).offset(5);
            make.width.height.mas_equalTo(25);
        }];
    }
    return self;
}

@end

@implementation CTDialogueRightCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bgView.backgroundColor = [UIColor hexColor:@"#D9D9D9"];
        self.bgView.layer.maskedCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft;
        self.segView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.sourceLabel.textColor = [UIColor hexColor:@"#333333"];
        self.targetLabel.textColor = [UIColor hexColor:@"#333333"];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-15);
            make.left.mas_greaterThanOrEqualTo(60);
        }];
        
        [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.right.equalTo(self.bgView.mas_left).offset(-5);
            make.width.height.mas_equalTo(25);
        }];
    }
    return self;
}

@end
