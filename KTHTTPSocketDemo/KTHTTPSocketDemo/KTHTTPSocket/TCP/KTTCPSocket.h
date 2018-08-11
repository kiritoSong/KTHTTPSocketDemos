//
//  KTTCPSocket.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/7.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>


@class KTTCPSocket;
@protocol KTTCPSocketDelegate <NSObject>

@optional

/**
 链接成功

 @param sock KTTCPSocket
 @param host 主机
 @param port 端口
 */
- (void)socket:(KTTCPSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;


/**
 最终链接失败
 连接失败 + N次重连失败

 @param sock KTTCPSocket
 */
- (void)socketCanNotConnectToService:(KTTCPSocket *)sock;


/**
 链接失败并重连

 @param sock KTTCPSocket
 @param error error
 */
- (void)socketDidDisconnect:(KTTCPSocket *)sock error:(NSError *)error;


/**
 接收到了数据

 @param sock KTTCPSocket
 @param data 二进制数据
 */
- (void)socket:(KTTCPSocket *)sock didReadData:(NSData *)data;

@end


/**
 对GCDAsyncSocket进行封装的工具类。
 具备自动重连、读写数据等基础操作
 */
@interface KTTCPSocket : NSObject

@property (nonatomic,readonly) NSString *host;//主机
@property (nonatomic,readonly) uint16_t port;//端口
@property (nonatomic) NSUInteger maxRetryCount;//重连次数
@property (nonatomic, weak) id<KTTCPSocketDelegate> delegate;


- (instancetype)init NS_UNAVAILABLE;

/**
 构造方法

 @param host 主机号
 @param port 端口号
 @return KTTCPSocket实例
 */
- (instancetype)initSocketWithHost:(NSString *)host port:(uint16_t)port NS_DESIGNATED_INITIALIZER;


/**
    关闭连接--注意关闭之后就没办法再次开启了。不然没办法判断socke对象该何时销毁
 */
- (void)close;


/**
    连接
 */
- (void)connect;

/**
    重连并且重置次数
 */
- (void)reconnect;


/**
    链接状态

 @return 是否已经链接
 */
- (BOOL)isConnected;


/**
 写入数据

 @param data 二进制数据
 */
- (void)writeData:(NSData *)data;
@end
