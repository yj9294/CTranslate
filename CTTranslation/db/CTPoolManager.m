//
//  CTPoolManager.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import "CTPoolManager.h"
#import <UIKit/UIApplication.h>

@implementation CTPoolManager

static CTPoolManager *instance = nil;
+ (CTPoolManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CTPoolManager alloc] init];
    });
    return instance;
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"CTTranslation"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                NSLog(@"translation pool path: %@", [storeDescription.URL absoluteString]);
                if (error) {
                    NSLog(@"%@", [NSString stringWithFormat:@"translation pool error %@, %@", error, error.userInfo]);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

- (void)savePool; {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"%@", [NSString stringWithFormat:@"translation pool error %@, %@", error, error.userInfo]);
        abort();
    }
}

@end
