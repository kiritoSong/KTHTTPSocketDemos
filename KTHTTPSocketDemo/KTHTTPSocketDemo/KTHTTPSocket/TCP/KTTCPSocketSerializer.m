//
//  KTTCPSocketSerializerForXXX.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocketSerializer.h"
#import "GetIPAddress.h"
#import "KTDataFormatter.h"
#import "NSString+MD5.h"
#import "KTTCPSocketRequest.h"
#import "KTTCPSocketResponse.h"
#import "KTTCPSocket+RequestIdentifier.h"
#import "KTTCPSocketManager.h"

NSData * getVerifyData (NSData *content ,NSString * ipAddress) {
    NSString * verifyStr = [NSString stringWithFormat:@"%@%@",ipAddress,content];
    NSData * md5BerifyData = [[verifyStr md5] dataUsingEncoding:NSUTF8StringEncoding];
    return md5BerifyData;
}

/**
 生成对应内容的二进制数据
 
 @param parameters 内容
 @param type 格式
 @return 二进制数据
 */
NSData * configContentData(id parameters,KTTCPSocketContentType type) {
    NSData *contentData;
    switch (type) {
        case KTTCP_contentType_json:
        {
            //内容转json
            NSString *  contentStr= ConvertToJsonStr(parameters);
            //json转data
            contentData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        }
            break;
        case KTTCP_contentType_XXModel:
        case KTTCP_contentType_YYModel:
        {
            //demo用不着
        }
            break;
            
        default:
            break;
    }
    
    return contentData;
}


/**
 生成二进制请求包
 
 @param type 通讯类型
 @param requestIdentifier 序列号
 @param parameters 内容
 @param contentType 内容类型
 @return 请求包
 */
NSMutableData * configFormattedData(KTTCPSocketRequestType type,uint32_t requestIdentifier,NSDictionary *parameters,KTTCPSocketContentType contentType) {
    NSMutableData * formattedData = [NSMutableData new];
    
    //内容转data
    NSData * encodingContent = configContentData(parameters,contentType);
    //协议拼接--类型标识符
    [formattedData appendData:DataFromInteger(type)];
    //协议拼接--协议版本号
    [formattedData appendData:DataFromInteger(KTTCPSocketVersion_1_0)];
    //协议拼接--序列号
    [formattedData appendData:DataFromInteger(requestIdentifier)];
    //协议拼接--内容类型
    [formattedData appendData:DataFromInteger(KTTCP_contentType_json)];
    //拼接校验和 ip+contentdata 后md5
    [formattedData appendData:getVerifyData(encodingContent,[GetIPAddress getIPAddress:NO])];
    //协议拼接--请求体长度
    uint32_t contengtLength = (uint32_t)encodingContent.length;
    [formattedData appendData:DataFromInteger(contengtLength)];
    //协议拼接--请求体
    if (encodingContent != nil) { [formattedData appendData:encodingContent]; }
    
    return formattedData;
}





@interface KTTCPSocketRequest ()
- (KTTCPSocketRequestType)type;
- (NSDictionary *)parameters;
- (void)setKTRequestIdentifier:(NSNumber *)identifier;
- (void)setFormattedData:(NSMutableData *)formattedData;
@end


@interface KTTCPSocketManager ()
- (void)setBuffer:(NSMutableData *)data;
- (NSMutableData *)buffer;
- (KTTCPSocket *)socket;
@end



/*****************<# 工作区 #>**************************/

@interface KTTCPSocketSerializer ()



@end

@implementation KTTCPSocketSerializer
- (void)setManager:(KTTCPSocketManager *)manager {
    _manager = manager;
}

- (void)configRequestDataWithSerializerWithRequest:(KTTCPSocketRequest *)req {
    
}

- (KTTCPSocketResponse *)tryGetResponseDataWithSerializer {
    return nil;
}
@end


@implementation KTTCPSocketSerializerForXXX


- (void)configRequestDataWithSerializerWithRequest:(KTTCPSocketRequest *)req {
    
    if (req.type == KTTCP_type_heatbeat) {
        
        [req setKTRequestIdentifier:@(KTTCP_identifier_heatbeat)];
        req.formattedData = configFormattedData(KTTCP_type_heatbeat, KTTCP_identifier_heatbeat, req.parameters, KTTCP_contentType_json);

        return;
        
    }
    uint32_t requestIdentifier = [self.manager.socket currentRequestIdentifier];//获取唯一序列号
    
    [req setKTRequestIdentifier:@(requestIdentifier)];//设置标识符
    req.formattedData = configFormattedData(req.type, requestIdentifier, req.parameters, KTTCP_contentType_json);//根据协议配置数据包
}

- (KTTCPSocketResponse *)tryGetResponseDataWithSerializer {
    
    NSData *totalReceivedData = self.manager.buffer;
    //1.头部 -- 每个Response报文必有的16个字节(url+serNum+respCode+contentLen)
    if (totalReceivedData.length < HeaderLength) { return nil; }
    
    //2.内容
    NSData *responseData;
    //根据定义的协议读取出Response.content的长度
    uint32_t responseContentLength = IntegerFromData([self.manager.buffer subdataWithRange:NSMakeRange(ReqTypeLength + VersionLength + IdentifierLength + ContentTypeLength + VerifyLength, ContentLength)]);
    
    //3.单个响应包长度  Response.content的长度加上必有的16个字节即为整个Response报文的长度
    uint32_t responseLength = HeaderLength + responseContentLength;
    if (totalReceivedData.length < responseLength) { return nil; }
    
    //4. 根据上面解析出的responseLength截取出单个Response报文
    if (self.manager.buffer.length < responseLength) { return nil; }//如果缓存池的长度不足一个数据包则不读取
    responseData = [totalReceivedData subdataWithRange:NSMakeRange(0, responseLength)];
    
    //更新缓存池  源缓存池-已经获取的长度
    self.manager.buffer = [[totalReceivedData subdataWithRange:NSMakeRange(responseLength, totalReceivedData.length - responseLength)] mutableCopy];
    
    KTTCPSocketResponseForXXX * response = [KTTCPSocketResponseForXXX responseWithData:responseData ipAddress:self.manager.socket.host];
    
    return response.verify?response:nil;//校验和通过则返回、否则部分返回
}
@end



/****************<# Demo #>********************/

/**
 生成二进制请求包
 
 @param type 通讯类型
 @param requestIdentifier 序列号
 @param parameters 内容
 @return 请求包
 */
NSMutableData * configFormattedDataForDemo(KTTCPSocketRequestType type,uint32_t requestIdentifier,NSDictionary *parameters) {
    NSMutableData * formattedData = [NSMutableData new];
    
    //内容转data
    NSData * encodingContent = [ConvertToJsonStr(parameters) dataUsingEncoding:NSUTF8StringEncoding];
    //协议拼接--类型标识符
    [formattedData appendData:DataFromInteger(type)];
    //协议拼接--序列号
    [formattedData appendData:DataFromInteger(requestIdentifier)];
    //协议拼接--请求体长度
    uint32_t contengtLength = (uint32_t)encodingContent.length;
    [formattedData appendData:DataFromInteger(contengtLength)];
    //协议拼接--请求体
    if (encodingContent != nil) { [formattedData appendData:encodingContent]; }
    
    return formattedData;
}


@implementation KTTCPSocketSerializerForDemo
- (void)configRequestDataWithSerializerWithRequest:(KTTCPSocketRequest *)req {
    
    if (req.type == KTTCP_type_heatbeat) {
        
        [req setKTRequestIdentifier:@(KTTCP_identifier_heatbeat)];
        req.formattedData = configFormattedDataForDemo(KTTCP_type_heatbeat, KTTCP_identifier_heatbeat, req.parameters);
        
        return;
        
    }
    uint32_t requestIdentifier = [self.manager.socket currentRequestIdentifier];//获取唯一序列号
    
    [req setKTRequestIdentifier:@(requestIdentifier)];//设置标识符
    req.formattedData = configFormattedDataForDemo(req.type, requestIdentifier, req.parameters);//根据协议配置数据包
}

- (KTTCPSocketResponse *)tryGetResponseDataWithSerializer {
    
    NSData *totalReceivedData = self.manager.buffer;
    
    //1.头部 -- 每个Response报文必有的16个字节(url+serNum+respCode+contentLen)
    if (totalReceivedData.length < HeaderLengthForDemo) { return nil; }
    
    //2.内容
    NSData *responseData;
    //根据定义的协议读取出Response.content的长度
    uint32_t responseContentLength = IntegerFromData([self.manager.buffer subdataWithRange:NSMakeRange(HeaderLengthForDemo - ContentLengthForDemo, ContentLengthForDemo)]);
    
    //3.单个响应包长度  Response.content的长度加上必有的16个字节即为整个Response报文的长度
    uint32_t responseLength = HeaderLengthForDemo + responseContentLength;
    if (totalReceivedData.length < responseLength) { return nil; }
    
    //4. 根据上面解析出的responseLength截取出单个Response报文
    if (self.manager.buffer.length < responseLength) { return nil; }//如果缓存池的长度不足一个数据包则不读取
    responseData = [totalReceivedData subdataWithRange:NSMakeRange(0, responseLength)];
    
    //更新缓存池  源缓存池-已经获取的长度
    self.manager.buffer = [[totalReceivedData subdataWithRange:NSMakeRange(responseLength, totalReceivedData.length - responseLength)] mutableCopy];
    
    KTTCPSocketResponseForDemo * response = [KTTCPSocketResponseForDemo responseWithData:responseData];
    
    return response;//校验和通过则返回、否则部分返回
}
@end
