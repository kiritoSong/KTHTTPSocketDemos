//
//  KTDataFormatter.m
//  KTHTTPSocketDemo
//
//  Created by 刘嵩野 on 2018/8/8.
//  Copyright © 2018年 kirito_song. All rights reserved.
//

#import "KTDataFormatter.h"

@implementation KTDataFormatter

NSString * ConvertToJsonStr(NSDictionary *dict) {
    NSError *error;
    if (!dict) { return nil;}
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}


NSData * DataFromInteger(uint32_t integer) {
    
    uint32_t time = integer;
    char *p_time = (char *)&time;
    static char str_time[4] = {0};
    for(int i = 4 - 1; i >= 0; i--) {
        str_time[i] = *p_time;
        p_time ++;
    }
    return [NSData dataWithBytes:&str_time length:4];
}

uint32_t IntegerFromData(NSData *data) {
    char *dataChar = (char *)data.bytes;
    char *index = (char *)&dataChar;
    char typeChar[4] = {0};
    for (int i = 0 ; i < data.length; i++) {
        typeChar[4 - 1 - i] = dataChar[i];
        index ++;
    }
    
    int integer;
    NSData *typeData = [NSData dataWithBytes:typeChar length:4];
    [typeData getBytes:&integer length:4];
    return integer;
}


@end
