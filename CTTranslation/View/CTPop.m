//
//  CTPop.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/2/27.
//

#import "CTPop.h"

@implementation CTPop

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.overlayView = [[UIView alloc] initWithFrame:self.bounds];
        [self.overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
        [self addSubview:self.overlayView];
    }
    return self;
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
