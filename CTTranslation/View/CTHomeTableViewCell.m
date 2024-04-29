//
//  CTHomeTableViewCell.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/11.
//

#import "CTHomeTableViewCell.h"
#import "UIView+CT.h"

@implementation CTHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor  = [UIColor hexColor:@"#12263A"];
        UIView *bgView  = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor hexColor:@"#5D6B83"];
        bgView.layer.cornerRadius = 10;
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.bottom.mas_equalTo(0);
        }];
        
        self.contentLabel = [UILabel lbText:@"" font:[UIFont pFont:12] color:[UIColor whiteColor]];
        self.contentLabel.numberOfLines = 2;
        [bgView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-35);
            make.centerY.mas_equalTo(0);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_arrow"]];
        [bgView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-10);
            make.width.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
