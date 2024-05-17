//
//  SVLaunchManager.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/8.
//

#import <Foundation/Foundation.h>
#import "CTMainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVLaunchManager : NSObject

@property (nonatomic, assign) BOOL isInit;

+ (SVLaunchManager *)shared;
- (void)launch;
@end

NS_ASSUME_NONNULL_END
