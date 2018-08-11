//
//  KTTCPNetWorking.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPNetWorking.h"
#import "KTTCPSocketManager.h"
#import "KTTCPSocketSerializer.h"
#import "KTTCPSocketRequest.h"

@interface KTTCPNetWorking ()
@property (nonatomic) KTTCPSocketManager * manager;
@end


static KTTCPNetWorking *networking;
@implementation KTTCPNetWorking
+(KTTCPNetWorking *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networking = [[KTTCPNetWorking alloc] init];
    });
    
    return networking;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[KTTCPSocketManager alloc]initWithTCPSocketSerializer:[KTTCPSocketSerializerForDemo new]];
        [self.manager contentWithHost:@"127.0.0.1" port:8080 blcok:^(NSError *error) {
            if (!error) {
                NSLog(@"链接成功");
            }else {
                NSLog(@"链接失败");
            }
        }];
        self.manager.timeoutInterval = 50;
        
    }
    return self;
}

- (void)sendMsgWithParameters:(NSDictionary *)parameters completionHandler:(void (^)(id responseObject))completionHandler failure:(void (^)(NSError *error))failure {
    
    KTTCPSocketRequest * request = [KTTCPSocketRequest requestWithType:KTTCP_type_dictionary parameters:parameters];
    [self.manager sendMsgWithRequest:request completionHandler:^(NSError *error, id response) {
        if (error) {
            failure(error);
        }else {
            completionHandler(response);
        }
    }];
    
}

- (void)GetWithUrl:(NSString *)url completionHandler:(void (^)(id))completionHandler failure:(void (^)(NSError *))failure {
    
    KTTCPSocketRequest * request = [KTTCPSocketRequest requestWithType:KTTCP_type_http_get parameters:@{@"url":url}];
    [self.manager sendMsgWithRequest:request completionHandler:^(NSError *error, id response) {
        if (error) {
            failure(error);
        }else {
            completionHandler(response);
        }
    }];
    
}
@end
