//
//  CTCameraViewController.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/13.
//

#import <UIKit/UIKit.h>
#import "CTBaseViewController.h"
#import "CTTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTCameraViewController : CTBaseViewController

@property (nonatomic, copy) void(^ocrComplete)(NSString *sourceText, NSString *targetText);
- (id)initWithSource:(CTTranslateModel *)sourceModel target:(CTTranslateModel *)targetModel;



@end

NS_ASSUME_NONNULL_END
