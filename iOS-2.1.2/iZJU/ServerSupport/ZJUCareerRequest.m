//
//  ZJUCareerRequest.m
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "ZJUCareerRequest.h"


@implementation ZJUCareerListItem

@synthesize ID,title,place;

@end

@implementation ZJUCareerDetailItem

@synthesize title,details;

@end

@implementation ZJUCareerRequest

- (NSURL*)url
{
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@",[self host],@"data",@"jiuye.php"]];
}

- (id)handler:(id)data error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    if (*outError)
        return nil;
    
    NSArray *jsonArray = (NSArray *)json;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *data in jsonArray) {
        ZJUCareerListItem *item = [[ZJUCareerListItem alloc] init];
        item.ID = [data objectForKey:@"id"];
        item.title = [data objectForKey:@"title"];
        item.place = [data objectForKey:@"seminar"];
        
        [results addObject:item];
    }
    return [NSArray arrayWithArray:results];
}

@end

@implementation ZJUCareerDetailRequest
@synthesize ID;

- (NSURL*)url
{
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@?id=%@",[self host],@"data",@"jiuye.php",self.ID]];
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
        ZJUCareerDetailItem *item = [[ZJUCareerDetailItem alloc] init];
        item.title = [json objectForKey:@"title"];
        item.details = [json objectForKey:@"detail"];
        
        return item;
    }
}

@end
