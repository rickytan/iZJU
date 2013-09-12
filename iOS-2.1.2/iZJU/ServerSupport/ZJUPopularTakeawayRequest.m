//
//  ZJUPopularTakeawayRequest.m
//  iZJU
//
//  Created by ricky on 12-10-14.
//
//

#import "ZJUPopularTakeawayRequest.h"

@implementation ZJUPopularTakeawayItem

@synthesize condition,dishes,mobileNum,phoneNum,remark,shopName;

@end

@implementation ZJUPopularTakeawayDish

@synthesize dishName,dishPrice;

@end

@implementation ZJUPopularTakeawayRequest

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
    if (*outError)
        return nil;
    
    NSDictionary *dic = [[json objectForKey:@"meishi"] objectForKey:@"waimai"];
    NSArray *jsonArray = [dic objectForKey:@"zjg"];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    for (NSDictionary *dic in jsonArray) {
        ZJUPopularTakeawayItem *item = [[ZJUPopularTakeawayItem alloc] init];
        item.shopName = [dic valueForKey:@"shop"];
        item.mobileNum = [dic valueForKey:@"mobile"];
        item.phoneNum = [dic valueForKey:@"phone"];
        item.remark = [dic valueForKey:@"remark"];
        item.condition = [dic valueForKey:@"condition"];
        NSArray *dishes = [dic objectForKey:@"dish"];
        NSMutableArray *dishObjs = [NSMutableArray arrayWithCapacity:dishes.count];
        for (NSDictionary *dish in dishes) {
            ZJUPopularTakeawayDish *D = [[ZJUPopularTakeawayDish alloc] init];
            D.dishName = [dish valueForKey:@"name"];
            D.dishPrice = [dish valueForKey:@"price"];
            [dishObjs addObject:D];
        }
        item.dishes = [NSArray arrayWithArray:dishObjs];
        [resultArray addObject:item];
    }
    
    jsonArray = [dic objectForKey:@"yq"];

    for (NSDictionary *dic in jsonArray) {
        ZJUPopularTakeawayItem *item = [[ZJUPopularTakeawayItem alloc] init];
        item.shopName = [dic valueForKey:@"shop"];
        item.mobileNum = [dic valueForKey:@"mobile"];
        item.phoneNum = [dic valueForKey:@"phone"];
        item.remark = [dic valueForKey:@"remark"];
        item.condition = [dic valueForKey:@"condition"];
        NSArray *dishes = [dic objectForKey:@"dish"];
        NSMutableArray *dishObjs = [NSMutableArray arrayWithCapacity:dishes.count];
        for (NSDictionary *dish in dishes) {
            ZJUPopularTakeawayDish *D = [[ZJUPopularTakeawayDish alloc] init];
            D.dishName = [dish valueForKey:@"name"];
            D.dishPrice = [dish valueForKey:@"price"];
            [dishObjs addObject:D];
        }
        item.dishes = [NSArray arrayWithArray:dishObjs];
        [resultArray addObject:item];
    }
    
    return resultArray;
}

@end
