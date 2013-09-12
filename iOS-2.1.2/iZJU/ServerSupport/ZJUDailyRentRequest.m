//
//  ZJUDailyRentRequest.m
//  iZJU
//
//  Created by ricky on 12-10-15.
//
//

#import "ZJUDailyRentRequest.h"

@implementation ZJUDailyRentRequest

- (NSURL*)url
{
//#ifdef DEBUG
    return [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.json"]];
//#else
//    return [NSURL URLWithString:[NSString stringWithFormat:
//                                 @"http://%@/%@/%@",[self host],[self version],@""]];
//#endif
}

- (id)handler:(id)data error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    return [[json objectForKey:@"zhusu"] objectForKey:@"rizu"];
}

@end
