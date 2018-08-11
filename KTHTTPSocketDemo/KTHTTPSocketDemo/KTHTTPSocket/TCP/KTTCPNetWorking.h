//
//  KTTCPNetWorking.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/9.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorUtils.h"

@interface KTTCPNetWorking : NSObject

+(KTTCPNetWorking *)sharedInstance;

- (void)sendMsgWithParameters:(NSDictionary *)parameters completionHandler:(void (^)(id responseObject))completionHandler failure:(void (^)(NSError *error))failure;

- (void)GetWithUrl:(NSString *)url completionHandler:(void (^)(id responseObject))completionHandler failure:(void (^)(NSError *error))failure;
@end
