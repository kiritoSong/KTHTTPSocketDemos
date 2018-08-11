//
//  KTTCPSocketHeartbeat.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocketHeartbeat.h"
#import "KTTCPSocketRequest.h"
#import "KTTCPSocketEnum.h"

@interface KTTCPSocketHeartbeat ()

@property (nonatomic, weak) KTTCPSocketManager *manger;

@property (nonatomic) void(^timeoutHandler)(void);
@property (nonatomic) NSTimer *timer;

@property (nonatomic) NSUInteger missTime;
@end

static NSUInteger maxMissTime = 3;
@implementation KTTCPSocketHeartbeat

+ (instancetype)heartbeatWithManger:(KTTCPSocketManager *)manager timeoutHandler:(void (^)(void))timeoutHandler {
    
    KTTCPSocketHeartbeat *heartbeat = [KTTCPSocketHeartbeat new];
    heartbeat.manger = manager;
    heartbeat.missTime = -1;
    heartbeat.timeoutHandler = timeoutHandler;
    return heartbeat;
}

- (void)start {
    
    [self stop];
    self.timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(sendHeatbeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.timer invalidate];
}

- (void)reset {
    self.missTime = -1;
    [self start];
}

- (void)sendHeatbeat {
    
    self.missTime += 1;
    if (self.missTime >= maxMissTime && self.timeoutHandler != nil) {
        //心跳超时 执行超时回调
        self.timeoutHandler();
        self.missTime = -1;
    }
    
    KTTCPSocketRequest * request = [KTTCPSocketRequest requestWithType:KTTCP_type_heatbeat parameters:@{@"ackNum": @(KTTCP_identifier_heatbeat)}];

    [self.manger sendMsgWithRequest:request completionHandler:nil];
}

- (void)handleServerAckNum:(uint32_t)ackNum {
    if (ackNum == KTTCP_identifier_heatbeat) {
        //序列号为客户端发送的心跳
        self.missTime = -1;
        return;
    }
    
    //服务端发起的Ping 需要回应序列号为服务器发送来的序列号
    KTTCPSocketRequest * request = [KTTCPSocketRequest requestWithType:KTTCP_type_heatbeat parameters:@{@"ackNum": @(ackNum)}];
    
    [self.manger sendMsgWithRequest:request completionHandler:nil];
}


@end
