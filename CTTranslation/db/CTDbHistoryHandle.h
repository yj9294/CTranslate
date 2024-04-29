//
//  CTDbHistoryHandle.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/19.
//

#import <Foundation/Foundation.h>
#import "HistoryEntity+CoreDataProperties.h"
#import "CTTranslateModel.h"
#import "CTHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTDbHistoryHandle : NSObject

+ (HistoryEntity *)add:(CTHistoryModel *)model;
+ (NSArray <CTHistoryModel *> *)loadAlls;
+ (BOOL)deleteWithModel:(CTHistoryModel *)model;
+ (BOOL)deleteWithModels:(NSArray <CTHistoryModel *> *)models;

+ (CTHistoryModel *)modelWithSourceModel:(CTTranslateModel *)sourceModel targetModel:(CTTranslateModel *)targetModel sourceText:(NSString *)sourceText targetText:(NSString *)targetText;

@end

NS_ASSUME_NONNULL_END
