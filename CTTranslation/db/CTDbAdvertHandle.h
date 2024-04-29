//
//  CTDbAdvertHandle.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import <Foundation/Foundation.h>
#import "TranslationEntity+CoreDataProperties.h"
#import "CTPosterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTDbAdvertHandle : NSObject

+ (NSArray <CTPosterModel *> *)saveDatas:(NSArray <CTPosterModel *> *)list;

@end

NS_ASSUME_NONNULL_END
