//
//  CTDialogueModel.m
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/15.
//

#import "CTDialogueModel.h"

@implementation CTDialogueModel

+ (CTDialogueModel *)modelWithSourceText:(NSString *)sourceText targetText:(NSString *)targetText sourceModel:(CTTranslateModel *)sourceModel targetModel:(CTTranslateModel *)targetModel isLeft:(BOOL)isLeft {
    CTDialogueModel *model = [[CTDialogueModel alloc] init];
    model.source = sourceText;
    model.target = targetText;
    model.sourceModel = sourceModel;
    model.targetModel = targetModel;
    model.isLeft = isLeft;
    model.isPlay = NO;
    return model;
}

@end
