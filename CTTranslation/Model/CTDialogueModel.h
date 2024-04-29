//
//  CTDialogueModel.h
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/15.
//

#import <Foundation/Foundation.h>
#import "CTTranslateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTDialogueModel : NSObject
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) CTTranslateModel *sourceModel;
@property (nonatomic, strong) CTTranslateModel *targetModel;
//是否正在播放
@property (nonatomic, assign) BOOL isPlay;
//是否是左边
@property (nonatomic, assign) BOOL isLeft;
+ (CTDialogueModel *)modelWithSourceText:(NSString *)sourceText targetText:(NSString *)targetText sourceModel:(CTTranslateModel *)sourceModel targetModel:(CTTranslateModel *)targetModel isLeft:(BOOL)isLeft;
@end

NS_ASSUME_NONNULL_END
