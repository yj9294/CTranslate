//
//  CTHistoryPop.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/19.
//

#import "CTPop.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTHistoryPop : CTPop

- (void)showWithComplete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
