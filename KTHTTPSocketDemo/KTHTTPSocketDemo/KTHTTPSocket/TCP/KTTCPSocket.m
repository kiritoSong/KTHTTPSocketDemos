//
//  KTTCPSocket.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/7.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocket.h"
#import "GCDAsyncSocket.h"
#import "RealReachability.h"

#import <UIKit/UIKit.h>

@interface KTTCPSocket ()<GCDAsyncSocketDelegate>

@property (nonatomic,readwrite) NSString *host;
@property (nonatomic,readwrite) uint16_t port;

@property (nonatomic) GCDAsyncSocket *socket;//socket
@property (nonatomic) dispatch_queue_t delegateQueue;//socket队列

@property (nonatomic) NSPort *machPort;//runloop常驻用
@property (nonatomic) NSThread *socketThread;//socket线程

@property (nonatomic) BOOL isConnecting;//是否正在连接
@property (nonatomic) NSInteger currentRetryCount;//当前重连次数
@end

//其实没啥用、用来标记动作的。比如readData与didWriteDataWithTag的代理方法
static NSUInteger socketTag = 1;

@implementation KTTCPSocket

#pragma mark - life cycle

- (instancetype)initSocketWithHost:(NSString *)host port:(uint16_t)port
{
    self = [super init];
    if (self) {
        self = [KTTCPSocket new];
        self.host = host;
        self.port = port;
        self.maxRetryCount = 5;//默认重连五次
        
        /*
            初始化Socket
         */
        const char *delegateQueueLabel = [[NSString stringWithFormat:@"%p_socketDelegateQueue", self] cStringUsingEncoding:NSUTF8StringEncoding];
        self.delegateQueue = dispatch_queue_create(delegateQueueLabel, DISPATCH_QUEUE_SERIAL);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
        
        /*
            2. 初始化Socket线程
         */
        self.machPort = [NSMachPort port];
        self.socket.IPv4PreferredOverIPv6 = NO;
        [NSThread detachNewThreadSelector:@selector(socketWillBeConnect) toTarget:self withObject:nil];
        
        /*
            3. 处理网络波动/前后台切换
         */
        //网络波动 RealReachability
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedNetworkChangedNotification:) name:kRealReachabilityChangedNotification object:nil];
        //后台 UIKit
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedAppBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
//网络波动
- (void)didReceivedNetworkChangedNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

//切换到后台
- (void)didReceivedAppBecomeActiveNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}


#pragma mark - Interface Method

//连接
- (void)connect {
    //已经在连接中||没网 {return}
    if (self.isConnecting) { NSLog(@"scoket正在连接"); return; }
    if (!self.isNetworkReachable) {  NSLog(@"没网"); return;}
    self.isConnecting = YES;
    
    [self disconnect];

    
    //自动重连有随机延迟。手动重连以及第一次链接是即时的
    BOOL isFirstTimeConnect = (self.currentRetryCount == self.maxRetryCount);
    if (isFirstTimeConnect) { NSLog(@"尝试第一次链接"); }
    int64_t delayTime = isFirstTimeConnect ? 0 : (arc4random() % 3) + 1;
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_global_queue(2, 0), ^{
        //去Socket连接线程进行连接 避免阻塞UI
        [self performSelector:@selector(socketConnect) onThread:self.socketThread withObject:nil waitUntilDone:YES];
    });
}

//断开连接
- (void)close {
    self.isConnecting = NO;
    [self disconnect];//断开连接
    [self performSelector:@selector(socketWillBeClose) onThread:self.socketThread withObject:nil waitUntilDone:YES];
}

//重连并且重置次数
- (void)reconnect {
    self.currentRetryCount = self.maxRetryCount;
    [self connect];
}


//连接状态
- (BOOL)isConnected {
    return self.socket.isConnected;
}

//发送数据
- (void)writeData:(NSData *)data {
    if (data.length == 0) { return; }
    
    [self.socket writeData:data withTimeout:-1 tag:socketTag];
}

#pragma mark - Private Method
#pragma mark Thread && RunLoop Method
//socket准备链接
- (void)socketWillBeConnect {
    if (self.socketThread == nil) {
        //保存异步线程
        self.socketThread = [NSThread currentThread];
        [[NSRunLoop currentRunLoop] addPort:self.machPort forMode:NSDefaultRunLoopMode];
        while (self.machPort) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }

}

//socket准备关闭
- (void)socketWillBeClose {
    [[NSRunLoop currentRunLoop] removePort:self.machPort forMode:NSDefaultRunLoopMode];
    [self.socketThread cancel];
    self.socket = nil;
    self.machPort = nil;
    self.socketThread = nil;
    self.delegateQueue = nil;
}


#pragma mark - GCDSocket Use method
#pragma mark Connect && Disconnect
//连接socket
- (void)socketConnect {
    
    [self.socket setDelegate:self delegateQueue:self.delegateQueue];
    //同步方法
    [self.socket connectToHost:self.host onPort:self.port error:nil];
    self.isConnecting = NO;
}
//断开socket连接
- (void)disconnect {
    if (!self.socket.isConnected) { return; }
    
    [self.socket setDelegate:nil delegateQueue:nil];
    [self.socket disconnect];
}

#pragma mark Reconnect
//尝试自动重连
- (void)tryToReconnect {
    if (self.isConnecting || !self.isNetworkReachable) {
        return;
    }
    
    self.currentRetryCount -= 1;
    //如果还有尝试次数就自动重连
    if (self.currentRetryCount >= 0) {
        NSLog(@"尝试重连");
        [self connect];
    } else if ([self.delegate respondsToSelector:@selector(socketCanNotConnectToService:)]) {
        //自动重连失败
        NSLog(@"重连失败");
        [self.delegate socketCanNotConnectToService:self];
    }
}

//网络波动后--判断是否需要重连
- (void)reconnectIfNeed {

    if (self.isConnecting || self.isConnected) { return; }
    //否则重置链接次数并重连
    [self reconnect];
}


#pragma mark - GCDAsyncSocketDelegate
//链接成功 读取数据
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"TCPSocket--连接成功");
    
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:self didConnectToHost:host port:port];
    }
    
    self.currentRetryCount = self.maxRetryCount;
    [self.socket readDataWithTimeout:-1 tag:socketTag];
}

//链接失败
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
//    NSLog(@"TCPSocket--连接已断开.error:%@", error);
    
    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:error:)]) {
        [self.delegate socketDidDisconnect:self error:error];
    }
    [self tryToReconnect];
}

//数据写入成功 开始读数据
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self.socket readDataWithTimeout:-1 tag:socketTag];
}
//数据读取成功 继续尝试读取
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if ([self.delegate respondsToSelector:@selector(socket:didReadData:)]) {
        [self.delegate socket:self didReadData:data];
    }
    
//    readDataWithTimeout方法会持续监听一次缓存区、当接收到数据立刻通过代理交付。这里相当于递归调用了
    [self.socket readDataWithTimeout:-1 tag:socketTag];
}


#pragma mark - setter && getter
-(void)setMaxRetryCount:(NSUInteger)maxRetryCount {
    _maxRetryCount = maxRetryCount;
    self.currentRetryCount = maxRetryCount;
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
