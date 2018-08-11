//
//  KTTCPSocketSerializer.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KTTCPSocketRequest;
@class KTTCPSocketManager;
@class KTTCPSocketResponse;

@protocol KTTCPSocketSerializerDelegate <NSObject>


/**
 与manager绑定以获取特殊属性
 weak
 
 @param manager KTTCPSocketManager
 */
- (void)setManager:(KTTCPSocketManager *)manager;
/**
 根据不同的策略将请求体格式化成数据包
 
 @param req 请求体
 
 */
- (void)configRequestDataWithSerializerWithRequest:(KTTCPSocketRequest *)req;


/**
 尝试根据不同的策略将响应数据包格式化成响应体
 
 @return 响应体
 */
- (KTTCPSocketResponse *)tryGetResponseDataWithSerializer;

@end


//策略基类--你也可以不继承他、只要实现代理就好。
@interface KTTCPSocketSerializer: NSObject<KTTCPSocketSerializerDelegate>
@property (nonatomic,weak) KTTCPSocketManager * manager;
@end

/**
 策略之一
 */
@interface KTTCPSocketSerializerForXXX: KTTCPSocketSerializer

@end


/**
 策略之二
 */
@interface KTTCPSocketSerializerForDemo: KTTCPSocketSerializer

@end

/**
 生成校验和
 本机ip+内容 后MD5
 @param content 内容
 @return 校验和
 */
FOUNDATION_EXPORT NSData * getVerifyData (NSData *content ,NSString * ipAddress);
