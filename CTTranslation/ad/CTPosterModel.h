//
//  CTPosterModel.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/2.
//

#import <Foundation/Foundation.h>
#import "CTAdInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTPosterModel : NSObject

//广告位名称
@property (nonatomic, strong) NSString *name;
//24h展示上限次数
@property (nonatomic, assign) int16_t msw;
//是否正在显示
@property (atomic, assign) BOOL isw;
//加载成功的时间
@property (atomic, assign) int64_t tld;
//显示成功的时间
@property (atomic, assign) int64_t tsw;
//开始加载的时间
@property (atomic, assign) int64_t tsld;
//上次更新时间
@property (atomic, assign) int64_t tut;
//24h点击上限次数
@property (nonatomic, assign) int16_t mck;
//当前显示次数
@property (atomic, assign) int16_t csw;
//是否正在加载
@property (atomic, assign) BOOL ild;
//ad
@property (nonatomic, strong) NSArray <CTAdInfoModel *> *advertList;
//位置类型
@property (nonatomic, assign) CTAdvertLocationType posty;
//当前点击次数
@property (atomic, assign) int16_t cck;

@end

NS_ASSUME_NONNULL_END
