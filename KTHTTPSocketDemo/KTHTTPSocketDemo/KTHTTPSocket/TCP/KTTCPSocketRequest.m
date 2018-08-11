//
//  KTTCPSocketRequest.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/7.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocketRequest.h"

@interface KTTCPSocketRequest ()


@property (nonatomic) NSMutableData *formattedData;
@property (nonatomic,readwrite) NSDictionary *parameters;
@property (nonatomic,readwrite) KTTCPSocketRequestType type;
@property (nonatomic,readwrite) NSNumber *requestIdentifier;//请求序列号
@end

@implementation KTTCPSocketRequest

#pragma mark - Interface

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

+(instancetype)requestWithType:(KTTCPSocketRequestType)type parameters:(NSDictionary *)parameters {

    KTTCPSocketRequest *request = [KTTCPSocketRequest new];//请求
    request.type = type;
    request.parameters = parameters;

    return request;
}

- (void)setKTRequestIdentifier:(NSNumber *)identifier {
    _requestIdentifier = identifier;
}

- (NSData *)requestData {
    return [self.formattedData copy];
}

@end
