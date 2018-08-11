//
//  KTTCPSocket+RequestIdentifier.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocket+RequestIdentifier.h"
#import "KTTCPSocketEnum.h"

@implementation KTTCPSocket (RequestIdentifier)
- (uint32_t)currentRequestIdentifier {
    static uint32_t currentRequestIdentifier;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        currentRequestIdentifier = KTTCP_identifier_max_notification;
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (currentRequestIdentifier + 1 == 0xffffffff) {
        currentRequestIdentifier = KTTCP_identifier_max_notification;
    }
    currentRequestIdentifier += 1;
    dispatch_semaphore_signal(lock);
    
    return currentRequestIdentifier;
}
@end
