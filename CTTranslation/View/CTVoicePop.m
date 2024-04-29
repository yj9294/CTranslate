//
//  CTVoicePop.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/21.
//

#import "CTVoicePop.h"
#import "UIView+CT.h"

@interface CTVoicePop ()

@property (nonatomic, copy) void(^complete)(void);

@end

@implementation CTVoicePop

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.overlayView.hidden = YES;
        UIImageView *imageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tip_voice"]];
        imageView.image = image;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(0);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(buttonActoin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(150);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(500);
        }];
    }
    return self;
}

- (void)buttonActoin {
    if (self.complete) self.complete();
    [self dismiss];
}

- (void)showWithComplete:(void(^)(void))complete {
    self.complete = complete;
    [self show];
}

@end
