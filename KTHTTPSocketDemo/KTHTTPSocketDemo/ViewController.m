//
//  ViewController.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/7.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "ViewController.h"
#import "KTTCPNetWorking.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)tcp:(id)sender {
    [[KTTCPNetWorking sharedInstance] sendMsgWithParameters:@{@"msms":@"sssasdasdasdassadasdasdasdass"} completionHandler:^(id responseObject) {
        NSLog(@"成功:::::\n%@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"失败:::::\n%@",error);
    }];

}


- (IBAction)Get:(id)sender {
    NSString * mafengwo = @"https://mapi.mafengwo.cn/travelguide/system/polling?app_code=cn.mafengwo.www&app_ver=8.6.0&channel_id=App%20Store&device_token=c9404470c1580ce653b6757d0821e51c31a7f0424811ffff8768f6897675981f&device_type=ios&hardware_model=iPhone9%2C1&idfa=AEF4D489-A886-42AA-A57D-A48C13CE4E85&idfv=F16145E9-97FF-4C24-AB12-A38DD55BCC30&mfwsdk_ver=20160401&o_lat=39.991910&o_lng=116.326865&oauth_consumer_key=4&oauth_nonce=50d1e8ae-6b7a-44e0-9419-d9e887a486bd&oauth_signature=2KT5XmGacZK%2Bb8PIN0EGSKCttnA%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1533890235&oauth_token=0_d5af5e71fbcea723b6af2ddae8ab084a&oauth_version=1.0&open_udid=F16145E9-97FF-4C24-AB12-A38DD55BCC30&screen_height=1334&screen_scale=2&screen_width=750&sys_ver=11.3&time_offset=480&x_auth_mode=client_auth";

    
    
    [[KTTCPNetWorking sharedInstance] GetWithUrl:mafengwo completionHandler:^(id responseObject) {
        NSLog(@"成功:::::\n%@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"失败:::::\n%@",error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
