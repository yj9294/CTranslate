//
//  PDBaseCell.m
//  SunUIKit
//
//  Created by cttranslation on 2020/6/26.
//

#import "PDBaseCell.h"

@implementation PDBaseCell

+ (NSString *)cellID {
    return NSStringFromClass(self);
}

/// 子类实现
+ (CGFloat)cellHeight {
    return 45;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    id cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self)];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:NSStringFromClass(self)];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (void)_setUp {
    self.showSepLine = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.sepLineColor = [UIColor lightGrayColor];
    self.sepLineInset = UIEdgeInsetsMake(0, 25, 0, 25);
    self.sepLine = [[UIView alloc] init];
    [self.sepLine setBackgroundColor:self.sepLineColor];
    CGRect rect = self.sepLine.frame;
    rect.size.height = 1;
    self.sepLine.frame = rect;
    [self.contentView addSubview:self.sepLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.sepLine setHidden:!self.showSepLine];
    if (self.showSepLine == YES) {
        CGRect rect = self.sepLine.frame;
        rect.origin.x = self.sepLineInset.left;
        rect.size.width = self.frame.size.width - self.sepLineInset.left - self.sepLineInset.right;
        rect.origin.y = self.frame.size.height - rect.size.height;
        self.sepLine.frame = rect;
    }
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setSepLineColor:(UIColor *)sepLineColor {
    _sepLineColor = sepLineColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
        [self.sepLine setBackgroundColor:highlighted ? [UIColor clearColor] : self.sepLineColor];
    } else {
        [self.sepLine setBackgroundColor:self.sepLineColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
        [self.sepLine setBackgroundColor:selected ? [UIColor clearColor] : self.sepLineColor];
        
        // 从高亮到Normal过渡时，Cell背景色变成Normal的状态下，有一个动画
        // 此时自定义分割线也需要加一个匹配背景色过渡的动画，才不突兀
        if (!selected && animated) {
            [self.sepLine setBackgroundColor:[UIColor clearColor]];
            [UIView animateWithDuration:0.6 animations:^{
                [self.sepLine setBackgroundColor:self.sepLineColor];
            }];
        }
    } else {
        [self.sepLine setBackgroundColor:self.sepLineColor];
    }
}

@end
