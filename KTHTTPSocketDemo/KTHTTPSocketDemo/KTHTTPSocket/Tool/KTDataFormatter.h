//
//  KTDataFormatter.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ReqTypeLength (4)/** 消息类型的长度 */
#define VersionLength (4)/** 协议版本号的长度 */
#define IdentifierLength (4)/** 消息序号的长度 */
#define ContentTypeLength (4)/** 内容类型的长度 */
#define VerifyLength (32)/** 校验和的长度 */
#define ContentLength (4)/** 消息有效载荷的长度 */
#define HeaderLength (ReqTypeLength + VersionLength + IdentifierLength + ContentTypeLength + VerifyLength + ContentLength)/** 消息响应的头部长度 */


//Demo版的协议结构
#define ReqTypeLengthForDemo (4)/** 消息类型的长度 */
#define IdentifierLengthForDemo (4)/** 消息序号的长度 */
#define ContentLengthForDemo (4)/** 消息有效载荷的长度 */
#define HeaderLengthForDemo (ReqTypeLengthForDemo + IdentifierLengthForDemo + ContentLengthForDemo)/** Demo消息响应的头部长度 */

@interface KTDataFormatter : NSObject

@end

/**
 字典转jsondata
 
 @param dict 字典
 @return jsondata
 */
FOUNDATION_EXPORT NSString * ConvertToJsonStr(NSDictionary *dict);
/**
 uint32_t转二进制数据
 
 @param integer uint32_t
 @return 二进制数据
 */
FOUNDATION_EXPORT NSData * DataFromInteger(uint32_t integer);

/**
 二进制数据转uint32_t
 
 @param data 二进制数据
 @return 二进制数据
 */
FOUNDATION_EXPORT uint32_t IntegerFromData(NSData *data);
