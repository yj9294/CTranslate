//
//  MMMButton.h
//  CTTranslation
//
//  Created by  CTTranslation on 2024/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//UIButton重新布局的类型
typedef NS_ENUM(NSInteger, LXButtonLayoutType){
    LXButtonLayoutTypeNone                = 0,         //默认
    LXButtonLayoutTypeImageLeft           = 1,        //图片在左边
    LXButtonLayoutTypeImageRight          = 2,        //图片在右边
    LXButtonLayoutTypeImageTop            = 3,        //图片在上边
    LXButtonLayoutTypeImageBottom         = 4         //图片在下边
};

@interface UIButton (CTL)

/**
 *  文本和图片间的间距
 */
@property (assign, nonatomic) CGFloat subMargin;

/**
 *  图片的缩放比例
 */
@property (assign,nonatomic) CGFloat scale;

/**
 *  布局的类型
 */
@property (assign, nonatomic) LXButtonLayoutType layoutType;

/**
 *  对按钮内部的图片和文本重新进行布局
 *
 *  @param layoutType 重新布局的类型
 *  @param subMargin  内部图片和文本之间的间距
 */
- (void) layoutWithType:(LXButtonLayoutType)layoutType subMargin:(CGFloat)subMargin;

/**
 *  设置button点击事件，扩大响应范围
 *
 *  @param top 上边距
 *  @param right 右边距
 *  @param bottom 下边距
 *  @param left 左边距
 */
/// top 上边距 right 右边距   bottom 下边距  left 左边距
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

/// 设置button点击事件，扩大相应范围
- (void)setEnlargeEdge:(CGFloat)size;

/// 缺省扩大15的点击范围
- (void)enlargeEdge;

@end

NS_ASSUME_NONNULL_END
