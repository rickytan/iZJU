//
//  ZJUActivityRequest.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "ZJUActivityRequest.h"

@implementation ZJUActivityListItem

@synthesize ID,date,title,place;

@end

@implementation ZJUActivityRequest

- (NSURL*)url
{
//#ifdef DEBUG
//    return [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.json"]];
//#else
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@",[self host],@"data",@"huodong.php"]];
//#endif
}

- (id)handler:(id)data
        error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    
    NSArray *jsonArray = json;
    if (jsonArray && jsonArray.count > 0) {
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (NSDictionary *dic in jsonArray) {
            ZJUActivityListItem *item = [[ZJUActivityListItem alloc] init];
            item.ID = [dic valueForKey:@"id"];
            item.title = [dic valueForKey:@"title"];
            item.place = [dic valueForKey:@"place"];
            item.date = [dic valueForKey:@"date"];
            [resultArray addObject:item];
        }
        return [NSArray arrayWithArray:resultArray];
    }
    else
        return nil;
}

@end

@implementation ZJUActivityDetailItem

@synthesize contractor,date,detail,host,ID,place,time,title,zhuban;

@end

@implementation ZJUActivityDetailRequest
@synthesize activityID;

- (NSURL*)url
{
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@?id=%@",[self host],@"data",@"huodong.php",self.activityID]];
}

- (id)handler:(id)data
        error:(NSError *__autoreleasing *)outError
{

    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    if (*outError)
        return nil;
    else {
        ZJUActivityDetailItem *item = [[ZJUActivityDetailItem alloc] init];
        item.ID = [json objectForKey:@"id"];
        item.host = [json objectForKey:@"host"];
        item.contractor = [json objectForKey:@"contractor"];
        item.date = [json objectForKey:@"date"];
        item.place = [json objectForKey:@"place"];
        item.title = [json objectForKey:@"title"];
        item.time = [json objectForKey:@"time"];
        item.zhuban = [json objectForKey:@"zhuban"];
        item.detail = [json objectForKey:@"detail"];
        
        return item;
    }
}

@end
