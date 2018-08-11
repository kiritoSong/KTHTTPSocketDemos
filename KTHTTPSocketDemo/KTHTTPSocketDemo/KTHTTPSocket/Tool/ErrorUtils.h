//
//  ErrorUtils.h
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#ifndef ErrorUtils_h
#define ErrorUtils_h

typedef enum : NSUInteger {
    KTNetworkTask_Success = 1,
    KTNetworkTaskError_TimeOut = 101,
    KTNetworkTaskError_CannotConnectedToInternet = 102,
    KTNetworkTaskError_Canceled = 103,
    KTNetworkTaskError_Default = 104,
    KTNetworkTaskError_NoData = 105,
    KTNetworkTaskError_NoMoreData = 106,
    KTNetworkTaskError_SocketNotConnect = 107,
    KTNetworkTaskError_SocketLost = 108
} KTNetworkTaskError;

typedef void(^KTNetworkTaskCompletionHander)(NSError *error,id response);


#endif /* ErrorUtils_h */
