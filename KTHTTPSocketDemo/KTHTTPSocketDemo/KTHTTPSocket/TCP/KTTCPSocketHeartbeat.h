//
//  KTTCPSocketHeartbeat.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTTCPSocketManager.h"

@interface KTTCPSocketHeartbeat : NSObject
+ (instancetype)heartbeatWithManger:(KTTCPSocketManager *)manager timeoutHandler:(void(^)(void))timeoutHandler;

- (void)stop;
- (void)reset;
- (void)handleServerAckNum:(uint32_t)ackNum;
@end
