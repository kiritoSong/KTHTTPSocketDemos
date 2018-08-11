//
//  KTTCPSocketRequest.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/7.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KTTCPSocketEnum.h"





/**
 将单次TCP需要发送的资源进行整合、类似NSURLRequest的作用
 */
@interface KTTCPSocketRequest : NSObject

@property (nonatomic, assign) NSUInteger timeoutInterval;//超时

/**
 请求构造方法

 @param type 请求类型
 @param parameters 内容数据
 @return 请求实例
 */
+(instancetype)requestWithType:(KTTCPSocketRequestType)type parameters:(NSDictionary *)parameters;


@end






