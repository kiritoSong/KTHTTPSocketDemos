//
//  KTTCPSocketManager.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorUtils.h"
#import "KTTCPSocket.h"
#import "KTTCPSocketSerializer.h"

@class KTTCPSocketManager;
@class KTTCPSocketTask;
@class KTTCPSocketRequest;
@class KTTCPSocketResponse;
typedef void (^KTTCPSocketManagerContentBlock)(NSError *error);

@interface KTTCPSocketManager : NSObject

@property (nonatomic) NSUInteger timeoutInterval;//超时
@property (nonatomic,readonly) KTTCPSocket *socket;
@property (nonatomic,readonly) NSArray<KTTCPSocketTask *> *tasks;//当前在执行的任务

/**
 通过指定协议的序列化方案进行初始化
 
 @param serializer 指定协议
 @return manager
 */
- (instancetype)initWithTCPSocketSerializer:(id<KTTCPSocketSerializerDelegate>)serializer;

/**
 用指定地址去连接

 @param host 主机
 @param port 端口
 @param block 回调
 */
- (void)contentWithHost:(NSString *)host port:(uint16_t)port blcok:(KTTCPSocketManagerContentBlock)block;

/**
 发送信息
 任务会自动开始
 @param request 请求体
 @param completionHandler 回调
 @return 任务
 */
- (KTTCPSocketTask *)sendMsgWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler;


/**
 创建任务
 任务不会自动开始 需要自己[task resume];
 @param request 请求体
 @param completionHandler 回调
 @return 任务
 */
- (KTTCPSocketTask *)TaskWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler;

@end
