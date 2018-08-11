//
//  KTTCPSocketManager.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocketManager.h"

#import "KTTCPSocketTask.h"
#import "KTTCPSocketResponse.h"
#import "ErrorUtils.h"
#import "KTDataFormatter.h"
#import "KTTCPSocketRequest.h"
#import "KTTCPSocketSerializer.h"
#import "KTTCPSocketHeartbeat.h"

@interface KTTCPSocketRequest ()

- (NSMutableData *)requestData;
- (void)setFormattedData:(NSMutableData *)formattedData;

@end

@interface KTTCPSocketTask ()

+ (instancetype)taskWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler;

- (KTTCPSocketRequest *)request;
- (void)setManager:(KTTCPSocketManager *)manager;
- (void)completeWithResponse:(KTTCPSocketResponse *)response error:(NSError *)error;

@end


@interface KTTCPSocketManager ()<KTTCPSocketDelegate>

@property (nonatomic,readwrite) KTTCPSocket *socket;
@property (nonatomic) NSMutableData *buffer;
@property (nonatomic) NSMutableDictionary<NSNumber *, KTTCPSocketTask *> *mutableTaskByTaskIdentifier;
@property (nonatomic) NSLock *tableLock;

@property (nonatomic) BOOL isReading;
@property (nonatomic) KTTCPSocketHeartbeat *heatbeat;

@property (nonatomic, copy) KTTCPSocketManagerContentBlock contentHandler;
@property (nonatomic) id <KTTCPSocketSerializerDelegate> serializer;//序列化

//线程锁
@property (nonatomic) NSLock *lock;
@end

@implementation KTTCPSocketManager


#pragma mari - Life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.buffer = [NSMutableData data];
        self.mutableTaskByTaskIdentifier = [NSMutableDictionary dictionary];
        self.serializer = [KTTCPSocketSerializerForXXX new];
        self.timeoutInterval = 15;
        self.lock = [[NSLock alloc]init];
        self.tableLock = [[NSLock alloc]init];
    }
    return self;
}


/**
 通过指定协议初始化

 @param serializer 指定协议
 @return manager
 */
- (instancetype)initWithTCPSocketSerializer:(id<KTTCPSocketSerializerDelegate>)serializer
{
    self = [self init];
    if (self) {
        self.serializer = serializer;
        [self.serializer setManager:self];
    }
    return self;
}

#pragma mark - Interface

- (void)contentWithHost:(NSString *)host port:(uint16_t)port blcok:(KTTCPSocketManagerContentBlock)block {
    self.contentHandler = block;
    self.socket = [[KTTCPSocket alloc]initSocketWithHost:host port:port];
    self.socket.delegate = self;

    [self.socket connect];
    self.heatbeat = [KTTCPSocketHeartbeat heartbeatWithManger:self timeoutHandler:^{
        [self reconnect];
    }];
}

- (KTTCPSocketTask *)sendMsgWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler {
    if (!request.timeoutInterval) { request.timeoutInterval = self.timeoutInterval; }
    [self.serializer configRequestDataWithSerializerWithRequest:request];
    
    KTTCPSocketTask *task = [self dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
    return task;
}

- (KTTCPSocketTask *)TaskWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler {
    if (!request.timeoutInterval) { request.timeoutInterval = self.timeoutInterval; }
    [self.serializer configRequestDataWithSerializerWithRequest:request];
    
    KTTCPSocketTask *task = [self dataTaskWithRequest:request completionHandler:completionHandler];
    return task;
    
}

#pragma mark - Interface (Friend)
//取消任务
- (void)cancelTaskWithTask:(KTTCPSocketTask *)task {
    if (!task) { return; }
    [task cancel];
}
//用socket发送数据包
- (void)resumeTask:(KTTCPSocketTask *)task {
    if (self.socket.isConnected) {
        [self.socket writeData:task.request.requestData];
    }else {
        KTError(@"TCP通道不通", KTNetworkTaskError_SocketNotConnect);
    }
}
#pragma mark - Utils
//新建数据请求任务 调用方通过此接口定义Request的收到响应后的处理逻辑
- (KTTCPSocketTask *)dataTaskWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler {
    
    __block NSNumber *taskIdentifier;
    //1. 根据Request新建Task
    KTTCPSocketTask *task = [KTTCPSocketTask taskWithRequest:request completionHandler:^(NSError *error, id result) {
        //4. Request已收到响应 从派发表中删除
        [self.tableLock lock];
        [self.mutableTaskByTaskIdentifier removeObjectForKey:taskIdentifier];
        [self.tableLock unlock];
        
        !completionHandler ?: completionHandler(error, result);
    }];
    //2. 设置Task.manager 后续会通过Task.manager向Socket中写入数据
    task.manager = self;
    taskIdentifier = task.taskIdentifier;
    //3. 将Task保存到派发表中
    [self.tableLock lock];
    [self.mutableTaskByTaskIdentifier setObject:task forKey:taskIdentifier];
    [self.tableLock unlock];
    
    return task;
}

#pragma mark - KTTCPSocketDelegate
//链接成功--发送心跳包
- (void)socket:(KTTCPSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.heatbeat reset];
    !self.contentHandler ?: self.contentHandler(nil);
    self.contentHandler = nil;
}

//链接失败并重连
- (void)socketDidDisconnect:(KTTCPSocket *)sock error:(NSError *)error {
    [self.heatbeat stop];
//    !self.contentHandler ?: self.contentHandler(error);
//    self.contentHandler = nil;
}

//链接断开--重连
- (void)socketCanNotConnectToService:(KTTCPSocket *)sock {
//    [self reconnect];
    NSLog(@"TCPManager::链接已断开");
    !self.contentHandler ?: self.contentHandler(KTError(@"Socket链接失败", KTNetworkTaskError_SocketNotConnect));
    self.contentHandler = nil;
}

//接收到数据--放入缓存池并解析数据
- (void)socket:(KTTCPSocket *)sock didReadData:(NSData *)data {
    [self.lock lock];
    [self.buffer appendData:data];//加入缓存池
    [self.lock unlock];
//    [self.heatbeat reset];
    
    [self readBuffer];//解析数据
}


#pragma mark - Private method
//重连
- (void)reconnect {
    
    for (KTTCPSocketTask *task in self.mutableTaskByTaskIdentifier.allValues) {
        [task completeWithResponse:nil error:KTError(@"TCP通道已断开", KTNetworkTaskError_SocketLost)];
    }
    [self.tableLock lock];
    self.buffer = [NSMutableData data];
    [self.mutableTaskByTaskIdentifier removeAllObjects];
    [self.tableLock unlock];
    
    [self.socket reconnect];
}

//递归截取Response报文 因为读取到的数据可能已经"粘包" 所以需要递归
- (void)readBuffer {
    if (self.isReading) { return; }
    
    self.isReading = YES;
    [self.lock lock];
    KTTCPSocketResponse *response = [self.serializer tryGetResponseDataWithSerializer];//截取单个响应报文
    [self.lock unlock];
    [self dispatchResponse:response];//将报文派发给对应的task
    self.isReading = NO;
    
    if (!response) { return; }
    [self readBuffer];//继续解析
}


//将Response报文解析Response 然后交由对应的Task进行派发
- (void)dispatchResponse:(KTTCPSocketResponse *)response {
    
    if (response == nil) { return; }
    
    //根据报文类型标识符进行分发
    if (response.type > KTTCP_type_max_notification) {/** 请求响应 */
        //根据序列号取出指定的task
        KTTCPSocketTask *task = self.mutableTaskByTaskIdentifier[response.requestIdentifier];
        //通过task将响应报文回调
        [task completeWithResponse:response error:nil];
    } else if (response.type == KTTCP_type_heatbeat) {/** 心跳 */
        NSLog(@"接收到心跳");
        [self.heatbeat handleServerAckNum:response.requestIdentifier.intValue];
    } else {/** 推送 */
        //自行处理
    }
}



#pragma mark - getter && setter
- (NSArray<KTTCPSocketTask *> *)tasks {
    return [self.mutableTaskByTaskIdentifier allValues];
}
@end
