//
//  KTTCPSocketResponse.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTTCPSocketEnum.h"


//照着HTTP的状态码就挺好
typedef enum : NSUInteger {
    KTTCPSocketResponseCode_Success = 200,
    KTTCPSocketResponseCode_Unkonwn = 304,
    KTTCPSocketResponseCode_UnkonwnContentType = 505,
} KTTCPSocketResponseCode;

/**
    响应体基类、不提供使用
 */
@interface KTTCPSocketResponse : NSObject


@property (nonatomic,readonly) KTTCPSocketRequestType type;//响应类型
@property (nonatomic,readonly) NSNumber *requestIdentifier;//序列号
@property (nonatomic,readonly) NSData *content;//内容


@end

/**
    某一应用协议的响应体
 */
@interface KTTCPSocketResponseForXXX : KTTCPSocketResponse

@property (nonatomic,readonly) KTTCPSocketContentType contentType;//内容类型
@property (nonatomic,readonly) BOOL verify;//校验和情况
@property (nonatomic,readonly) KTTCPSocketVersion version;//协议版本号


/**
 对响应体进行初始化
 
 @param data 数据包
 @param ipAddress 数据包源地址
 @return 响应体
 */
+ (instancetype)responseWithData:(NSData *)data ipAddress:(NSString *)ipAddress;
@end




/****************<# Demo #>********************/
/**
 某一应用协议的响应体
 */
@interface KTTCPSocketResponseForDemo : KTTCPSocketResponse



/**
 对响应体进行初始化
 
 @param data 数据包
 @return 响应体
 */
+ (instancetype)responseWithData:(NSData *)data;
@end


