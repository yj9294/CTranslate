//
//  PDURLProtocol.h
//  SunUIKit
//
//  Created by cttranslation on 2021/12/7.
//  网络拦截

#import <Foundation/Foundation.h>
@class PDRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface PDURLProtocol : NSURLProtocol

@property (nonatomic, strong) NSMutableArray<PDRequestModel *> *models;
@property (nonatomic, copy) void(^requestUpdate)(NSArray<PDRequestModel *> *logs);

@end

@interface PDRequestManager: NSObject

@property (nonatomic, strong) NSMutableArray<PDRequestModel *> *models;
@property (nonatomic, copy) void(^requestUpdate)(NSArray<PDRequestModel *> *logs);

+ (PDRequestManager *)sharedInstance;
- (void)updateRequest:(PDRequestModel *)model;
- (void)clearAllRequests;
- (void)handleRequest:(void(^)(NSArray<PDRequestModel *> *logs))block;
@end

@interface PDRequestModel : NSObject
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *formatTime;
@property (nonatomic, strong) NSString *formatCode;
@property (nonatomic, strong) NSString *formatBody;
@property (nonatomic, assign, getter=isAvailable) BOOL available;
@end

NS_ASSUME_NONNULL_END
