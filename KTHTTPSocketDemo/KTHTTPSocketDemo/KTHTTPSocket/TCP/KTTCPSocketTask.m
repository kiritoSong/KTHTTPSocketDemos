//
//  KTTCPSocketTask.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocketTask.h"
#import "KTTCPSocketRequest.h"
#import "KTTCPSocketResponse.h"
#import "KTTCPSocketManager.h"
#import "ErrorUtils.h"

NSError * KTError(NSString *domain, NSInteger code) {
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

NSError * taskError(NSUInteger code) {
    
#define TaskErrorCase(responeCode, errorDomain) case responeCode: return KTError(errorDomain, code)
    switch (code) {
            
            TaskErrorCase(KTTCPSocketTaskState_Canceled, @"任务已取消");
            TaskErrorCase(KTNetworkTaskError_TimeOut, @"请求超时");
            TaskErrorCase(KTTCPSocketResponseCode_UnkonwnContentType, @"响应类型未知");
            TaskErrorCase(KTTCPSocketResponseCode_Unkonwn, @"未知错误");
            
        default: return nil;
    }
}

@interface KTTCPSocketRequest ()

- (NSNumber *)requestIdentifier;

@end


@interface KTTCPSocketManager ()
- (void)cancelTaskWithTask:(KTTCPSocketTask *)task;
- (void)resumeTask:(KTTCPSocketTask *)task;
@end

@interface KTTCPSocketTask ()

@property (nonatomic,readwrite) KTTCPSocketTaskState state;//任务状态
@property (nonatomic,readwrite) NSNumber *taskIdentifier;//任务ID

@property (nonatomic, weak) KTTCPSocketManager *manager;//启动用
@property (nonatomic, strong) NSTimer *timer;//超时

@property (nonatomic, strong) KTTCPSocketRequest *request;
@property (nonatomic, copy) KTNetworkTaskCompletionHander completionHandler;


@property (nonatomic, strong) KTTCPSocketTask *keeper;//保持自己不被释放
@end

@implementation KTTCPSocketTask

#pragma mark - Interface
- (void)cancel {
    if (![self canResponse]) { return; }
    
    self.state = KTTCPSocketTaskState_Canceled;
    [self completeWithResult:nil error:taskError(KTTCPSocketTaskState_Canceled)];
    [self.manager cancelTaskWithTask:self];
}

- (void)resume {
    if (self.state != KTTCPSocketTaskState_Suspended) { return; }
    //发起Request的同时也启动一个timer timer超时直接返回错误并忽略后续的Response
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    self.state = KTTCPSocketTaskState_Running;
    [self.manager resumeTask:self];//通知manager将task.request的数据写入Socket
}



#pragma mark - Interface(Friend)

+ (instancetype)taskWithRequest:(KTTCPSocketRequest *)request completionHandler:(KTNetworkTaskCompletionHander)completionHandler {
    
    KTTCPSocketTask *task = [KTTCPSocketTask new];
    task.state = KTTCPSocketTaskState_Suspended;
    task.taskIdentifier = request.requestIdentifier;
    task.request = request;
    task.completionHandler = completionHandler;
    task.keeper = task;
    return task;
}


- (void)completeWithResponse:(KTTCPSocketResponse *)response error:(NSError *)error {
    //如果已经结束、或者取消
    if (![self canResponse]) { return; }
    
    id result;
    if (error == nil) {
        
        if (response == nil) {
            error = taskError(KTTCPSocketResponseCode_Unkonwn);
        }else {
            result = [NSJSONSerialization JSONObjectWithData:response.content options:0 error:nil];
        }
    }

    [self completeWithResult:result error:error];
}


#pragma mark - Private method
- (void)requestTimeout {
    if (![self canResponse]) { return; }
    
    self.state = KTTCPSocketTaskState_Completed;
    [self completeWithResult:nil error:taskError(KTNetworkTaskError_TimeOut)];
}


- (void)completeWithResult:(id)result error:(NSError *)error {
    
    self.state = (self.state >= KTTCPSocketTaskState_Canceled ? self.state : KTTCPSocketTaskState_Completed);
    [self.timer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        !self.completionHandler ?: self.completionHandler(error, result);
        self.completionHandler = nil;
        self.keeper = nil;
    });
}

- (BOOL)canResponse {
    return self.state <= KTTCPSocketTaskState_Running;
}

@end
