//
//  KTTCPSocketEnum.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#ifndef KTTCPSocketEnum_h
#define KTTCPSocketEnum_h

//通讯类型标识符
typedef enum : NSUInteger {
    //    心跳
    KTTCP_type_heatbeat = 0x00000001,
    KTTCP_type_notification_xxx = 0x00000002,
    KTTCP_type_notification_yyy = 0x00000003,
    KTTCP_type_notification_zzz = 0x00000004,
    
    //    通知类型最多到400
    KTTCP_type_max_notification = 0x00000400,
    
    KTTCP_type_dictionary = 0x00000402,//内容为字典类型
    
    KTTCP_type_http_get = 0x00000403//内容为字典类型
    
} KTTCPSocketRequestType;

//协议版本
typedef enum : NSUInteger {
    
    KTTCPSocketVersion_1_0 = 0x00000001
    
    
} KTTCPSocketVersion;

//通讯序列号 -- 普通通讯以 KTTCP_identifier_max_notification为基础递增
typedef enum : NSUInteger {
    //    心跳
    KTTCP_identifier_heatbeat = 0x00000001,
    KTTCP_identifier_notification_xxx = 0x00000002,
    KTTCP_identifier_notification_yyy = 0x00000003,
    KTTCP_identifier_notification_zzz = 0x00000004,
    
    //    通知类型最多到400
    KTTCP_identifier_max_notification = 0x00000400,
    
    
} KTTCPSocketIdentifier;

//内容类型
typedef enum : NSUInteger {
    KTTCP_contentType_json = 0x00000001,//这里只用json了
    KTTCP_contentType_XXModel = 0x00000002,
    KTTCP_contentType_YYModel = 0x00000003,
    
} KTTCPSocketContentType;



#endif /* KTTCPSocketEnum_h */
