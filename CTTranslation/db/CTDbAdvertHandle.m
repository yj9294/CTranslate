//
//  CTDbAdvertHandle.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import "CTDbAdvertHandle.h"
#import "CTPoolManager.h"

@implementation CTDbAdvertHandle

+ (NSArray <CTPosterModel *> *)saveDatas:(NSArray <CTPosterModel *> *)list {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval allSeconds = 24 * 60 * 60;
    NSArray *datas = [NSArray arrayWithArray:list];
    NSMutableArray <CTPosterModel *> *models = [NSMutableArray arrayWithCapacity:list.count];
    NSManagedObjectContext *ctx = [CTPoolManager shared].persistentContainer.viewContext;
    for (CTPosterModel *data in datas) {
        NSPredicate *perdicate = [NSPredicate predicateWithFormat:@"name = %@", data.name];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TranslationEntity"];
        NSError *error = nil;
        [request setPredicate:perdicate];
        NSArray *result = [ctx executeFetchRequest:request error:&error];
        if (result.count > 0) {
            TranslationEntity *entity = result.firstObject;
            entity.name = data.name;
            if (data.cck > 0) {
                entity.cck = data.cck;
            }
                
            if (data.csw > 0) {
                entity.csw = data.csw;
            }
                
            if (data.tut > 0) {
                entity.tut = data.tut;
            }
                
            NSTimeInterval timeInterval = fabs(entity.tut - time);
            if (timeInterval > allSeconds) {
                entity.csw = 0;
                entity.cck = 0;
                entity.tut = time;
            }
            [models addObject:[self ct_modelWithEntity:entity oldData:data]];
        } else {
            //本地没有对应数据
            NSEntityDescription *description = [NSEntityDescription entityForName:@"TranslationEntity" inManagedObjectContext:ctx];
            TranslationEntity *entity = (TranslationEntity *)[[NSManagedObject alloc] initWithEntity:description insertIntoManagedObjectContext:ctx];
            entity.name = data.name;
            entity.tut = time;
            entity.csw = 0;
            entity.cck = 0;
            [models addObject:[self ct_modelWithEntity:entity oldData:data]];
        }
    }
    NSError *error = nil;
    @try {
        [ctx save:&error];
    } @catch (NSException *exception) {
        NSLog(@"<pool>: %@", exception);
    } @finally {
        
    }
    return models;
}

+ (CTPosterModel *)ct_modelWithEntity:(TranslationEntity *)entity oldData:(CTPosterModel *)data {
    CTPosterModel *model = [[CTPosterModel alloc] init];
    model.cck = entity.cck;
    model.csw = entity.csw;
    model.tut = entity.tut;
    model.name = entity.name;
    model.msw = data.msw;
    model.posty = data.posty;
    model.mck = data.mck;
    model.tld = data.tld;
    model.tsw = data.tsw;
    model.tsld = data.tsld;
    model.advertList = data.advertList;
    
    if (data.isw == 0) {
        model.isw = NO;
    } else {
        model.isw = YES;
    }
    if (data.ild == 0) {
        model.ild = NO;
    } else {
        model.ild = YES;
    }
    return model;
}

@end
