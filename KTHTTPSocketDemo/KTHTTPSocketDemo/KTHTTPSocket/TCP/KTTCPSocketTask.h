//
//  KTTCPSocketTask.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    KTTCPSocketTaskState_Suspended = 0,
    KTTCPSocketTaskState_Running = 1,
    KTTCPSocketTaskState_Canceled = 2,
    KTTCPSocketTaskState_Completed = 3
} KTTCPSocketTaskState;


@interface KTTCPSocketTask : NSObject

@property (nonatomic,readonly) KTTCPSocketTaskState state;//任务状态
@property (nonatomic,readonly) NSNumber *taskIdentifier;//任务ID

- (void)cancel;
- (void)resume;


@end

FOUNDATION_EXPORT NSError * KTError(NSString *domain, NSInteger code);
