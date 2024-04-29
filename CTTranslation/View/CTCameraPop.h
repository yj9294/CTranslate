//
//  CTCameraPop.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/21.
//

#import "CTPop.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTCameraPop : CTPop

- (void)showWithComplete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
