//
//  ZJUPopularFoodRequest.m
//  iZJU
//
//  Created by ricky on 12-10-14.
//
//

#import "ZJUPopularFoodRequest.h"

@implementation ZJUFoodItem

@synthesize shopName,recomand,remark,mobileNum,phoneNum,address,category,discount,price,scale;

@end

@implementation ZJUPopularFoodRequest

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
    
    NSDictionary *dic = [[json objectForKey:@"meishi"] objectForKey:@"meishi"];
    NSArray *jsonArray = [dic objectForKey:@"zjg"];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    for (NSDictionary *dic in jsonArray) {
        ZJUFoodItem *item = [[ZJUFoodItem alloc] init];
        item.shopName = [dic valueForKey:@"shop"];
        item.mobileNum = [dic valueForKey:@"mobile"];
        item.phoneNum = [dic valueForKey:@"phone"];
        item.address = [dic valueForKey:@"address"];
        item.recomand = [dic valueForKey:@"recommond"];
        item.remark = [dic valueForKey:@"remark"];
        item.price = [dic valueForKey:@"price"];
        item.discount = [dic valueForKey:@"discount"];
        item.category = [dic valueForKey:@"tag"];
        item.scale = [dic valueForKey:@"scale"];
        [resultArray addObject:item];
    }
    
    jsonArray = [dic objectForKey:@"yq"];
    for (NSDictionary *dic in jsonArray) {
        ZJUFoodItem *item = [[ZJUFoodItem alloc] init];
        item.shopName = [dic valueForKey:@"shop"];
        item.mobileNum = [dic valueForKey:@"mobile"];
        item.phoneNum = [dic valueForKey:@"phone"];
        item.address = [dic valueForKey:@"address"];
        item.recomand = [dic valueForKey:@"recommond"];
        item.remark = [dic valueForKey:@"remark"];
        item.price = [dic valueForKey:@"price"];
        item.discount = [dic valueForKey:@"discount"];
        item.category = [dic valueForKey:@"tag"];
        item.scale = [dic valueForKey:@"scale"];
        [resultArray addObject:item];
    }
    return [NSArray arrayWithArray:resultArray];
}

@end
