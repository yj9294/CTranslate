//
//  CTStatisticAnalysis.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTStatisticAnalysis : NSObject

+ (void)saveEvent:(NSString *)event params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
