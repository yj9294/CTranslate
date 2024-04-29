//
//  PluginEntry.m
//  MonkeyTestDylib
//
//  Created by 孙浪 on 2023/12/19.
//

#import "PluginEntry.h"
#import "PDDebugAssistant.h"
#import "Aspects.h"

@implementation PluginEntry

+ (void)load {
    [NSClassFromString(@"SceneDelegate") aspect_hookSelector:@selector(scene:willConnectToSession:options:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [PDDebugAssistant fire];
    } error:nil];
}
@end
