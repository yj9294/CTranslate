//
//  CTLaunchViewController.h
//  CTTranslation
//
//  Created by  cttranslation on 2023/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTLaunchView : UIView
@property (nonatomic, strong) UIProgressView *progressView;
@end

@interface CTLaunchViewController : UIViewController
- (void)launch;
@end

NS_ASSUME_NONNULL_END
