//
//  CTBaseViewController.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/2/1.
//

#import <UIKit/UIKit.h>
#import "CTStatisticAnalysis.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTBaseViewController : UIViewController

@property (nonatomic, assign) BOOL vcIsDid;
@property (nonatomic, assign) BOOL vcIsShowAding;
@property (nonatomic, assign) BOOL isSubstitute;

- (void)didVC;
@end

NS_ASSUME_NONNULL_END
