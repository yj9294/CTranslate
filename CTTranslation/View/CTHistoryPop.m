//
//  CTHistoryPop.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/19.
//

#import "CTHistoryPop.h"
#import "UIView+CT.h"

@interface CTHistoryPop ()

@property (nonatomic, copy) void(^complete)(void);

@end

@implementation CTHistoryPop

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor hexColor:@"#D9D9D9"];
        contentView.layer.cornerRadius = 10;
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        
        UILabel *deleteLabel = [UILabel lbText:@"Delete" font:[UIFont fontWithSize:18 weight:UIFontWeightMedium] color:[UIColor hexColor:@"#333333"]];
        [contentView addSubview:deleteLabel];
        [deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(25);
        }];
        
        UILabel *contentLabel = [UILabel lbText:@"Are you sure you want to delete these records?" font:[UIFont fontWithSize:18 weight:UIFontWeightRegular] color:[UIColor hexColor:@"#333333"]];
        contentLabel.numberOfLines = 0;
        [contentView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(52);
            make.right.mas_equalTo(-52);
            make.top.equalTo(deleteLabel.mas_bottom).offset(15);
        }];
        
        UIButton *determineButton = [UIButton btTitle:@"Determine"];
        [determineButton bgImage:[UIImage imageNamed:@"history_button_bg"]];
        [determineButton addTarget:self action:@selector(determineActoin) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:determineButton];
        [determineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(contentLabel.mas_bottom).offset(20);
            make.width.mas_equalTo(235);
            make.height.mas_equalTo(46);
        }];
        
        UIButton *cancelButton = [UIButton btTitle:@"Cancel"];
        [cancelButton bgImage:[UIImage imageNamed:@"history_bottom_cancel"]];
        [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(determineButton.mas_bottom).offset(15);
            make.width.mas_equalTo(235);
            make.height.mas_equalTo(46);
            make.bottom.mas_equalTo(-25);
        }];
    }
    return self;
}

- (void)determineActoin {
    if (self.complete) self.complete();
    [self dismiss];
}

- (void)showWithComplete:(void(^)(void))complete {
    self.complete = complete;
    [self show];
}

@end
