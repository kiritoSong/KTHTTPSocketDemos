//
//  KTTCPSocketResponse.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//




#import "KTTCPSocketResponse.h"
#import "KTDataFormatter.h"
#import "KTTCPSocketSerializer.h"

@interface KTTCPSocketResponse ()

@end

@implementation KTTCPSocketResponse

@end



@interface KTTCPSocketResponseForXXX ()
//基类的几个属性要作为私有变量实现一下.或者你也可以直接self.xxx给他们都赋值一遍。但是外面就不能readonly了
{
    KTTCPSocketRequestType _type;//响应类型
    KTTCPSocketVersion _version;//协议版本号
    NSNumber *_requestIdentifier;//序列号
    NSData *_content;//内容
}

@property (nonatomic) NSString * ipAddress;
@property (nonatomic) NSData *data;
@property (nonatomic) uint32_t contentLength;

@property (nonatomic,readwrite) KTTCPSocketContentType contentType;//内容类型
@property (nonatomic,readwrite) BOOL verify;//校验和情况
@end

@implementation KTTCPSocketResponseForXXX
+ (instancetype)responseWithData:(NSData *)data ipAddress:(NSString *)ipAddress{
    if (data.length < HeaderLength) {
        return nil;
    }
    
    KTTCPSocketResponseForXXX *response = [KTTCPSocketResponseForXXX new];
    response.data = data;
    response.ipAddress = ipAddress;
    return response;
}

- (KTTCPSocketRequestType)type {
    if (!_type) {
        _type = IntegerFromData([self.data subdataWithRange:NSMakeRange(0, ReqTypeLength)]);
    }
    return _type;
}

- (KTTCPSocketVersion)version {
    if (!_verify) {
        _version = IntegerFromData([self.data subdataWithRange:NSMakeRange(ReqTypeLength, VersionLength)]);
    }
    return _verify;
}

- (NSNumber *)requestIdentifier {
    if (!_requestIdentifier) {
        _requestIdentifier = @(IntegerFromData([self.data subdataWithRange:NSMakeRange(ReqTypeLength + VersionLength, IdentifierLength)]));
    }
    return _requestIdentifier;
}

- (KTTCPSocketContentType)contentType {
    if (!_contentType) {
        _contentType = IntegerFromData([self.data subdataWithRange:NSMakeRange(ReqTypeLength + VersionLength + IdentifierLength, ContentTypeLength)]);
    }
    return _contentType;
}

- (BOOL)verify {
    if (!_verify) {
        NSData * verifyData = [self.data subdataWithRange:NSMakeRange(ReqTypeLength + VersionLength + IdentifierLength + ContentTypeLength, VerifyLength)];
        
        NSData * verify = getVerifyData(self.content,self.ipAddress);
        
        _verify = [verifyData isEqualToData:verify];
    }
    return _verify;
}

- (uint32_t)contentLength {
    if (!_contentLength) {
        _contentLength = IntegerFromData([self.data subdataWithRange:NSMakeRange(ReqTypeLength + VersionLength + IdentifierLength + ContentTypeLength + VerifyLength, ContentLength)]);
    }
    return _contentLength;
}

- (NSData *)content {
    if (!_content) {
        _content = [self.data subdataWithRange:NSMakeRange(HeaderLength, self.contentLength)];
    }
    return _content;
}
@end



/****************<# Demo #>********************/
@interface KTTCPSocketResponseForDemo ()
//基类的几个属性要作为私有变量实现一下.或者你也可以直接self.xxx给他们都赋值一遍。但是外面就不能readonly了
{
    KTTCPSocketRequestType _type;//响应类型
    NSNumber *_requestIdentifier;//序列号
    NSData *_content;//内容
}

@property (nonatomic) NSData *data;
@property (nonatomic) uint32_t contentLength;

@end

@implementation KTTCPSocketResponseForDemo
+ (instancetype)responseWithData:(NSData *)data{
    if (data.length < HeaderLengthForDemo) {
        return nil;
    }
    
    KTTCPSocketResponseForDemo *response = [KTTCPSocketResponseForDemo new];
    response.data = data;
    return response;
}


- (KTTCPSocketRequestType)type {
    if (!_type) {
        _type = IntegerFromData([self.data subdataWithRange:NSMakeRange(0, ReqTypeLengthForDemo)]);
    }
    return _type;
}


- (NSNumber *)requestIdentifier {
    if (!_requestIdentifier) {
        _requestIdentifier = @(IntegerFromData([self.data subdataWithRange:NSMakeRange(ReqTypeLengthForDemo , IdentifierLengthForDemo)]));
    }
    return _requestIdentifier;
}



- (uint32_t)contentLength {
    if (!_contentLength) {
        _contentLength = IntegerFromData([self.data subdataWithRange:NSMakeRange(ReqTypeLengthForDemo + IdentifierLengthForDemo, ContentLengthForDemo)]);
    }
    return _contentLength;
}

- (NSData *)content {
    if (!_content) {
        _content = [self.data subdataWithRange:NSMakeRange(HeaderLengthForDemo, self.contentLength)];
    }
    return _content;
}
@end

