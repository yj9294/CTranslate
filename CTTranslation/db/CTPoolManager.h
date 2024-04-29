//
//  CTPoolManager.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface CTPoolManager : NSObject
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
+ (CTPoolManager *)shared;
- (void)savePool;
@end

NS_ASSUME_NONNULL_END
