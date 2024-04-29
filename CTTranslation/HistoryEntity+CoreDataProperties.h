//
//  HistoryEntity+CoreDataProperties.h
//  
//
//  Created by  cttranslation on 2024/3/19.
//
//

#import "HistoryEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface HistoryEntity (CoreDataProperties)

+ (NSFetchRequest<HistoryEntity *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *sourceLang;
@property (nullable, nonatomic, copy) NSString *sourceText;
@property (nullable, nonatomic, copy) NSString *targetLang;
@property (nullable, nonatomic, copy) NSString *targetText;
@property (nullable, nonatomic, copy) NSString *historyId;
@property (nonatomic) int64_t time;
@property (nonatomic) int16_t sourceType;
@property (nonatomic) int16_t targetType;

@end

NS_ASSUME_NONNULL_END
