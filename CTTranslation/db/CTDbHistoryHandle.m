//
//  CTDbHistoryHandle.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/19.
//

#import "CTDbHistoryHandle.h"
#import "CTPoolManager.h"

@implementation CTDbHistoryHandle

+ (HistoryEntity *)add:(CTHistoryModel *)model {
    NSError *error;
    NSManagedObjectContext *ctx = [CTPoolManager shared].persistentContainer.viewContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:ctx];
    HistoryEntity *obj = (HistoryEntity *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:ctx];
    
    obj.sourceText = model.sourceText;
    obj.sourceLang = model.sourceLang;
    obj.sourceType = model.sourceType;
    obj.targetText = model.targetText;
    obj.targetLang = model.targetLang;
    obj.targetType = model.targetType;
    obj.historyId = model.historyId;
    obj.time = [[NSDate date] timeIntervalSince1970];
     
    BOOL result = [ctx save:&error];
    if (result) {
        return obj;
    } else {
        NSLog(@"<pool> error:%@", error.localizedDescription);
    }
    return nil;
}

+ (NSArray <CTHistoryModel *> *)loadAlls {
    NSManagedObjectContext *ctx = [CTPoolManager shared].persistentContainer.viewContext;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:ctx];
    [request setEntity:entity];
    request.sortDescriptors = @[sortDescriptor];
    NSError *error = nil;
    NSArray *datas = [[ctx executeFetchRequest:request error:&error] mutableCopy];
    
    if (!error) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:datas.count];
        for (HistoryEntity *obj in datas) {
            CTHistoryModel *model = [[CTHistoryModel alloc] init];
            model.sourceText = obj.sourceText;
            model.sourceLang = obj.sourceLang;
            model.sourceType = obj.sourceType;
            model.targetText = obj.targetText;
            model.targetLang = obj.targetLang;
            model.targetType = obj.targetType;
            model.historyId = obj.historyId;
            [array addObject:model];
        }
        return [array copy];
    } else {
        NSLog(@"<pool> error:%@", error.localizedDescription);
    }
    return nil;
}

+ (BOOL)deleteWithModel:(CTHistoryModel *)model {
    return [self deleteWithModels:@[model]];
}

+ (BOOL)deleteWithModels:(NSArray <CTHistoryModel *> *)models {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:models.count];
    for (CTHistoryModel *model in models) {
        [array addObject:model.historyId];
    }
    NSManagedObjectContext *ctx = [CTPoolManager shared].persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HistoryEntity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"historyId IN %@", array];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *results = [ctx executeFetchRequest:fetchRequest error:&error];

    if (results == nil) {
        // 处理错误
        NSLog(@"<pool> Fetch error: %@", error);
        return NO;
    } else {
        for (NSManagedObject *object in results) {
            [ctx deleteObject:object];
        }

        if (![ctx save:&error]) {
            NSLog(@"<pool> Save error: %@", error);
            return NO;
        }
        return YES;
    }
}

+ (CTHistoryModel *)modelWithSourceModel:(CTTranslateModel *)sourceModel targetModel:(CTTranslateModel *)targetModel sourceText:(NSString *)sourceText targetText:(NSString *)targetText {
    CTHistoryModel *model = [[CTHistoryModel alloc] init];
    model.sourceText = sourceText;
    model.sourceLang = sourceModel.name;
    model.sourceType = sourceModel.type;
    model.targetText = targetText;
    model.targetLang = targetModel.name;
    model.targetType = targetModel.type;
    model.historyId = [[NSUUID UUID] UUIDString];
    return model;
}

@end
