//
//  ZJUSchoolBusDataRequest.m
//  iZJU
//
//  Created by sheng tan on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZJUSchoolBusDataRequest.h"

@implementation ZJUSchoolBusDataItem
@synthesize from,to,time,duration,place,type,remark;

@end

@implementation ZJUSchoolBusDataRequest

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
    
    NSArray *jsonArray = [json objectForKey:@"xiaoche"];
    if (jsonArray && jsonArray.count > 0) {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (NSDictionary *dic in jsonArray) {
            ZJUSchoolBusDataItem *item = [[ZJUSchoolBusDataItem alloc] init];
            item.from = [dic valueForKey:@"from"];
            item.to = [dic valueForKey:@"to"];
            item.place = [dic valueForKey:@"place"];
            item.time = [dic valueForKey:@"start"];
            item.type = [dic valueForKey:@"type"];
            item.duration = [dic valueForKey:@"duration"];
            item.remark = [dic valueForKey:@"remark"];
            [resultArray addObject:item];
        }
        return [NSArray arrayWithArray:resultArray];
    }
    else
        return nil;
}

@end
