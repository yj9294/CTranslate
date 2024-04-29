//
//  PDURLProtocol.m
//  SunUIKit
//
//  Created by cttranslation on 2021/12/7.
//

#import "PDURLProtocol.h"
#import <objc/runtime.h>

static NSString * const kPDURLProtocolHandledKey = @"kPDURLProtocolHandledKey";

@interface PDURLProtocol ()<NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) PDRequestModel *requestModel;
@property (nonatomic, assign) BOOL isIgnoreData; //是否忽略数据
@end

@implementation PDURLProtocol

static BOOL __isQQ = NO;

+ (BOOL )isQQ {
    static NSString *flag;
    if (!flag) {
        flag = @"已经判断";
        if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.mqq"]) {
            __isQQ = YES;
        }
    }
    return __isQQ;
}

#pragma mark NSURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if ([NSURLProtocol propertyForKey:kPDURLProtocolHandledKey inRequest:request]) {
        return NO;
    }

    if ([self isQQ]) {
        NSString *userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
        if (userAgent && [userAgent containsString:@"AppleWebKit"]) {
            //屏蔽webview的网络请求
            return NO;
        }
    }
    
    if ([request.URL.absoluteString containsString:@"localhost"]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    [NSURLProtocol setProperty:@(YES) forKey:kPDURLProtocolHandledKey inRequest:(NSMutableURLRequest *)request];
    return [request mutableCopy];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

- (void)startLoading {
    self.mutableData = [NSMutableData data];
    self.requestModel = [PDRequestModel new];
    [self.requestModel setRequest:self.request];
    [self.requestModel setBeginDate:[NSDate date]];
    [[PDRequestManager sharedInstance] updateRequest:self.requestModel];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    mainQueue.maxConcurrentOperationCount = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:mainQueue];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.request];
    [task resume];
}

- (void)stopLoading {
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    long long contentLength = [response expectedContentLength];
    if (contentLength > 10240) {
        //如果大于10M, 忽略数据
        self.isIgnoreData = YES;
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.isIgnoreData) {
        [self.mutableData appendData:data];
    }
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }

    [self.requestModel setResponse:task.response];
    
    [self.requestModel setError:error];
    [self.requestModel setData:self.mutableData];
    [self.requestModel setEndDate:[NSDate date]];
    [[PDRequestManager sharedInstance] updateRequest:self.requestModel];
}

@end

@interface PDRequestManager ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray *saveLogs;
@end

@implementation PDRequestManager

+ (PDRequestManager *)sharedInstance {
    static PDRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("com.tk.net.manager", DISPATCH_QUEUE_SERIAL);
        self.models = [NSMutableArray new];
        self.saveLogs = [NSMutableArray array];
    }
    return self;
}

- (NSString *)commonDirectoryWithPathName:(NSString *)name {
    NSString *basePath = NSTemporaryDirectory();
    if (basePath.length < 40) {
        return @"";
    }
    NSString *path = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", @"AppResources", name]];
    return path;
}

- (void)saveInfos:(NSArray *)infos path:(NSString *)path {
    NSData *data = [NSJSONSerialization dataWithJSONObject:infos options:NSJSONWritingPrettyPrinted error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        string = [@"," stringByAppendingString:[string substringFromIndex:1]];
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [handle seekToEndOfFile];
        unsigned long long offset = [handle offsetInFile];
        [handle seekToFileOffset:offset-1];
        [handle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [handle closeFile];
    } else {
        [data writeToFile:path atomically:YES];
    }
}

- (void)addLog:(PDRequestModel *)log {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setValue:log.request.URL.absoluteString forKey:@"url"]; //链接
    [dict setValue:log.request.HTTPMethod forKey:@"method"]; //请求方法
    [dict setValue:log.formatCode forKey:@"code"]; //状态
    [dict setValue:log.formatTime forKey:@"duration"]; //耗时
    [dict setValue:[NSNumber numberWithLongLong:log.beginDate.timeIntervalSince1970 * 1000] forKey:@"startTime"]; //开始时间
    [dict setValue:log.formatBody forKey:@"body"]; //body
    __block NSMutableString *headers = [NSMutableString new];
    [log.request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
      [headers appendFormat:@"%@: %@\n", key, val];
    }];
    [dict setValue:headers forKey:@"header"]; //header
        
    NSString *responseDesc = @"";
    if (log.error) {
        responseDesc = log.error.description;
        if (!responseDesc) responseDesc = @"";
        [dict setValue:responseDesc forKey:@"error"]; //error
    } else if (log.data) {
        id jsonDecoded = [NSJSONSerialization JSONObjectWithData:log.data options:kNilOptions error:nil];
        if (jsonDecoded) {
            responseDesc = [jsonDecoded description];
        } else {
            responseDesc = [[NSString alloc] initWithData:log.data encoding:NSUTF8StringEncoding];
        }
        if (!responseDesc) responseDesc = @"";
        [dict setValue:responseDesc forKey:@"response"]; //response
    }
    [self.saveLogs addObject:dict];
}

- (void)updateRequest:(PDRequestModel *)model {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        if (![weakSelf.models containsObject:model]) {
            [weakSelf.models insertObject:model atIndex:0];
        }
        
        if (model.endDate) {
            [weakSelf addLog:model];
        }
        
        if (weakSelf.requestUpdate) {
            weakSelf.requestUpdate(weakSelf.models);
        }
    });
}

- (void)clearAllRequests {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf.models removeAllObjects];
        if (weakSelf.requestUpdate) {
            weakSelf.requestUpdate(weakSelf.models);
        }
    });
}

- (void)handleRequest:(void(^)(NSArray<PDRequestModel *> *logs))block {
    NSAssert(!self.requestUpdate, @"您已添加过handleRequest，再次添加会导致之前代码设置的handleRequest失效，请更改设计策略，在同一个handleRequestBlock作统一处理！");
    [PDRequestManager injectNSURLSessionConfiguration];
    [NSURLProtocol registerClass:[PDURLProtocol class]];
    self.requestUpdate = ^(NSArray<PDRequestModel *> * _Nonnull logs) {
        if (block) {
            block(logs);
        }
    };
}

+ (void)injectNSURLSessionConfiguration{
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    Method originalMethod = class_getInstanceMethod(cls, @selector(protocolClasses));
    Method stubMethod = class_getInstanceMethod([self class], @selector(protocolClasses));
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

+ (void)injectWeb {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if([cls respondsToSelector:sel]) {
        //这里我们只需要匹配http和https的scheme
        NSArray *array = @[@"http", @"https"];
        for (NSString *scheme in array) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
        }
    }
}

+ (void)unRegisterWeb {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    if([cls respondsToSelector:sel]) {
        //这里我们只需要匹配http和https的scheme
        NSArray *array = @[@"http", @"https"];
        for (NSString *scheme in array) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
        }
    }
}

- (NSArray *)protocolClasses{
    return @[[PDURLProtocol class]];
}

- (void)dealloc{
    [NSURLProtocol unregisterClass:[PDURLProtocol class]];
}

@end

@implementation PDRequestModel

- (NSString *)formatTime {
    if (self.beginDate && self.endDate) {
        NSTimeInterval interval = [self.endDate timeIntervalSinceDate:self.beginDate];
        if (interval < 1) {
            return [NSString stringWithFormat:@"%@ms", [NSNumber numberWithInt:interval * 1000]];
        }
        return [[self autoFormatCNY:interval * 100] stringByAppendingString:@"s"];
    }
    
    return @"pending";
}

- (NSString *)autoFormatCNY:(NSInteger)milli {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:0];
    
    NSString *CNY = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:milli / 100.0f]];
    return CNY;
}

- (NSString *)formatCode {
    if (self.error) {
        return self.error.localizedDescription;
    }
    
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        return [NSString stringWithFormat:@"%@", @(((NSHTTPURLResponse *)self.response).statusCode)];
    }
    
    return @"pending";
}

- (NSString *)formatBody {
    if (self.request.HTTPBody) {
        return [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    } else if (self.request.HTTPBodyStream) {
        uint8_t sub[1024] = {0};
        NSInputStream *inputStream = self.request.HTTPBodyStream;
        NSMutableData *bodyData = [[NSMutableData alloc] init];
        [inputStream open];
        while ([inputStream hasBytesAvailable]) {
            NSInteger len = [inputStream read:sub maxLength:1024];
            if (len > 0 && inputStream.streamError == nil) {
                [bodyData appendBytes:(void *)sub length:len];
            } else {
                break;
            }
        }
        [inputStream close];
        return [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    }
    return @"";
}

- (BOOL)isAvailable {
    if (self.error) {
        return NO;
    }
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (((NSHTTPURLResponse *)self.response).statusCode != 200) {
            return NO;
        }
    }    
    return YES;
}

- (NSString *)debugDescription {
    __block NSMutableString *curl = [NSMutableString stringWithFormat:@"curl -v -X %@", self.request.HTTPMethod];
    
    [curl appendFormat:@" \'%@\'",  self.request.URL.absoluteString];
    
    [self.request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
      [curl appendFormat:@" -H \'%@: %@\'", key, val];
    }];
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"] ||
        [self.request.HTTPMethod isEqualToString:@"PUT"] ||
        [self.request.HTTPMethod isEqualToString:@"PATCH"]) {
      [curl appendFormat:@" -d \'%@\'", self.formatBody];
    }
    
    return curl;
}

@end
