//
//  HistoryEntity+CoreDataProperties.m
//  
//
//  Created by  cttranslation on 2024/3/19.
//
//

#import "HistoryEntity+CoreDataProperties.h"

@implementation HistoryEntity (CoreDataProperties)

+ (NSFetchRequest<HistoryEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"HistoryEntity"];
}

@dynamic sourceLang;
@dynamic sourceText;
@dynamic targetLang;
@dynamic targetText;
@dynamic historyId;
@dynamic time;
@dynamic sourceType;
@dynamic targetType;

@end
