//
//  TranslationEntity+CoreDataProperties.h
//  
//
//  Created by  cttranslation on 2024/3/11.
//
//

#import "TranslationEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TranslationEntity (CoreDataProperties)

+ (NSFetchRequest<TranslationEntity *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nonatomic) int64_t tut;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t csw;
@property (nonatomic) int16_t cck;

@end

NS_ASSUME_NONNULL_END
