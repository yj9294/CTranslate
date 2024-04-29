//
//  CTAdInfoModel.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/3/7.
//

#import <Foundation/Foundation.h>
#import "SVAdAllType.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTAdInfoModel : NSObject

//广告id
@property (nonatomic, strong) NSString *aid;
//优先级
@property (nonatomic, assign) NSUInteger level;
//广告类型
@property (nonatomic, assign) CTAdvertType type;

@end

NS_ASSUME_NONNULL_END
