//
//  TranslationEntity+CoreDataProperties.m
//  
//
//  Created by  cttranslation on 2024/3/11.
//
//

#import "TranslationEntity+CoreDataProperties.h"

@implementation TranslationEntity (CoreDataProperties)

+ (NSFetchRequest<TranslationEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TranslationEntity"];
}

@dynamic tut;
@dynamic name;
@dynamic csw;
@dynamic cck;

@end
