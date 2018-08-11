//
//  KTTCPSocket+RequestIdentifier.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTTCPSocket.h"

@interface KTTCPSocket (RequestIdentifier)
/**
 获取递增的序列号
 每一个socket对象独自维护
 @return 序列号
 */
- (uint32_t)currentRequestIdentifier;
@end
