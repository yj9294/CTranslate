//
//  PDLogManager.m
//  SunUIKit
//
//  Created by cttranslation on 2020/8/3.
//

#import "PDLogManager.h"
#include "fishhook.h"

static void(*__old_nslog)(NSString *format, ...);

// 定义一个新的函数
static void __new_nslog(NSString *format, ...) {
    va_list vl;
    va_start(vl, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:vl];
    va_end(vl);
    
    [[PDLogManager shared] addLogs:log];
    __old_nslog(@"%@", log);
}

typedef NS_OPTIONS(NSUInteger, DDLogFlag){
    DDLogFlagError      = (1 << 0),
    DDLogFlagWarning    = (1 << 1),
    DDLogFlagInfo       = (1 << 2),
    DDLogFlagDebug      = (1 << 3),
    DDLogFlagVerbose    = (1 << 4)
};

@interface DDLogMessage : NSObject
@property (readonly, nonatomic) DDLogFlag flag;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) NSString *fileName;
@property (readonly, nonatomic) NSUInteger line;
@end

@interface PDLogManager ()
@property (nonatomic, strong) NSMutableArray *logs;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDateFormatter *briefFormatter;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation PDLogManager

+ (void)configure {
    [self shared];
}

+ (PDLogManager *)shared {
    static PDLogManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PDLogManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("com.tk.log.manager", DISPATCH_QUEUE_SERIAL);
        self.maxLogNum = 1000;
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
        self.briefFormatter = [[NSDateFormatter alloc] init];
        self.briefFormatter.dateFormat = @"HH:mm:ss:SSS";
        self.logs = [NSMutableArray arrayWithCapacity:self.maxLogNum];
        [self start];
    }
    return self;
}

/// 配置日志信息
- (void)start {
    rebind_symbols((struct rebinding[1]){"NSLog", (void *)__new_nslog, (void **)&__old_nslog}, 1);
}

- (void)addLogs:(NSString *)log {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        NSString *briefTime = [weakSelf.briefFormatter stringFromDate:[NSDate date]];
        NSString *desc = [NSString stringWithFormat:@"%@ %@", briefTime, log];
        
        [weakSelf.logs insertObject:desc atIndex:0];
        if (weakSelf.logs.count >= weakSelf.maxLogNum) {
            [weakSelf.logs removeLastObject];
        }
        if (weakSelf.logManagerRecord) {
            weakSelf.logManagerRecord(weakSelf.logs);
        }
    });
}

- (void)clearLogs {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf.logs removeAllObjects];
        
        if (weakSelf.logManagerRecord) {
            weakSelf.logManagerRecord(weakSelf.logs);
        }
    });
}

@end
