//
//  PDLogManager.h
//  SunUIKit
//
//  Created by cttranslation on 2020/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLogManager : NSObject

+ (void)configure;
+ (PDLogManager *)shared;
- (void)addLogs:(NSString *)log;
- (void)clearLogs;

// logan上传
// 最多保存最近250条记录
@property (nonatomic, assign) NSUInteger maxLogNum;
@property (nonatomic, copy) void(^logManagerRecord)(NSArray *logs);

@end

NS_ASSUME_NONNULL_END
