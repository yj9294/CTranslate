//
//  SV.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/25.
//

#import "UIView+CT.h"
#import "MBProgressHUD.h"

@implementation UIView (CT)

- (UIViewController *)viewController {
    id obj = [self nextResponder];
    while (obj) {
        if ([obj isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)obj;
        }
        obj = [obj nextResponder];
    }
    return nil;
}

- (UINavigationController *)navController {
    id obj = [self nextResponder];
    while (obj) {
        if ([obj isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)obj;
        }
        obj = [obj nextResponder];
    }
    return nil;
}

@end

@implementation UIView (Tip)

+ (UIView *)ct_showLoading:(NSString *)text {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [self showLoading:text inView:window];
    return window;
}

+ (MBProgressHUD *)showLoading:(NSString *)text inView:(UIView *)inView {
    [self ct_hideLoading:inView];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    [hud.label setText:text.length > 0 ? text : @"loading..."];
    [hud setAnimationType:MBProgressHUDAnimationFade];
//    [hud setMode:MBProgressHUDModeCustomView];
    [hud.label setNumberOfLines:0];
    [hud.label setFont:[UIFont fontWithSize:16]];
    [hud.label setTextColor:[UIColor hexColor:@"#333333"]];
    [hud setMinSize:CGSizeMake(301, 117)];
        
    UIColor *bgColor = [UIColor hexColor:@"#D9D9D9"];
    
    [hud.bezelView setColor:bgColor];
    hud.bezelView.layer.cornerRadius = 10;
    [hud.bezelView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    return hud;
}

+ (void)ct_hideLoading {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [MBProgressHUD hideHUDForView:window animated:YES];
}

+ (void)ct_hideLoading:(UIView *)inView {
    [MBProgressHUD hideHUDForView:inView animated:YES];
}

+ (void)ct_tipToast:(nullable NSString *)text {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [self ct_hideLoading:window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    [hud setMode:MBProgressHUDModeText];
    hud.label.numberOfLines = 0;
    hud.label.text = text.length > 0 ? text : @"loading...";
    hud.offset = CGPointMake(0.f, 0.f);
    [hud hideAnimated:YES afterDelay:1];
}

+ (void)ct_tipForeplayWithComplete:(void(^)(void))complete {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        if (complete) complete();
    });
}

@end

@implementation UIImage (CT)

+ (UIImage *)ct_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//+ (UIImage *)createHDUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
//    CGRect extent = CGRectIntegral(image.extent);
//    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
//    
//    size_t width = CGRectGetWidth(extent) * scale;
//    size_t height = CGRectGetHeight(extent) * scale;
//    
//    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
//    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
//    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
//    CGContextScaleCTM(bitmapRef, scale, scale);
//    CGContextDrawImage(bitmapRef, extent, bitmapImage);
//    
//    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
//    CGColorSpaceRelease(cs);
//    CGContextRelease(bitmapRef);
//    CGImageRelease(bitmapImage);
//    UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
//    CGImageRelease(scaledImage);
//    return newImage;
//}

+ (UIImage *)ct_deepImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    CGContextRef overlayContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(overlayContext, [[UIColor colorWithWhite:0 alpha:0.2f] CGColor]);
    CGContextFillRect(overlayContext, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)ct_imageWithAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGContextSetAlpha(context, alpha);
    CGContextDrawImage(context, area, self.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//+ (UIImage *)generateQrcodeImageWithStr:(NSString *)QcodeStr size:(float)size {
//    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//    [filter setDefaults];
//    NSData *data = [QcodeStr dataUsingEncoding:NSUTF8StringEncoding];
//    [filter setValue:data forKeyPath:@"inputMessage"];
//    return [self createHDUIImageFormCIImage:[filter outputImage] withSize:size];
//}

- (UIImage *)ct_adjustImageColorByFactor:(CGFloat)factor {
    CIImage *ciImage = [[CIImage alloc] initWithImage:self];

    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(factor) forKey:kCIInputContrastKey];

    CIImage *outputCIImage = [filter outputImage];

    if (outputCIImage) {
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:outputCIImage fromRect:[outputCIImage extent]];
        UIImage *adjustedImage = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(cgImage);

        return adjustedImage;
    }

    return nil;
}
@end

@implementation UIButton (CT)

+ (UIButton *)btTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithSize:16];
    [button tColor:[UIColor whiteColor]];
    [button bgImage:[UIImage imageNamed:@"button_bg"]];
    return button;
}

- (void)bgColor:(UIColor *)color {
    [self setBackgroundImage:[UIImage ct_imageWithColor:color] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage ct_imageWithColor:[color colorWithAlphaComponent:0.5]] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage ct_deepImageWithColor:color] forState:UIControlStateHighlighted];
}

- (void)bgImage:(UIImage *)image {
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:[image ct_adjustImageColorByFactor:1.3] forState:UIControlStateDisabled];
    [self setBackgroundImage:[image ct_adjustImageColorByFactor:0.7] forState:UIControlStateHighlighted];
}

- (void)tColor:(UIColor *)color {
    
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)nImage:(UIImage *)image hImage:(UIImage * _Nullable)sImage {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    sImage = [sImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:[image ct_imageWithAlpha:0.5] forState:UIControlStateDisabled];
    [self setImage:[image ct_imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    
    if (sImage != nil) {
        [self setImage:sImage forState:UIControlStateSelected];
        [self setImage:[sImage ct_imageWithAlpha:0.5] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}

@end

@implementation UILabel (CT)

//- (void)adjustSize {
//    CGFloat width = self.frame.size.width;
//    [self sizeToFit];
//    CGRect rect = self.frame;
//    rect.size.width = width;
//    self.frame = rect;
//}

+ (UILabel *)lbText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentLeft;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    return label;
}

@end
