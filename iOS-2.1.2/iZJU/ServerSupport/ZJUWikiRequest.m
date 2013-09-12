//
//  ZJUWikiRequest.m
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "ZJUWikiRequest.h"

@implementation ZJUWikiItem

@synthesize detail,title;

@end

@implementation ZJUWikiRequest

- (NSURL*)url
{
    return [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.json"]];
}

- (id)handler:(id)data error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    if (*outError)
        return nil;
    NSArray *jsonArray = [json objectForKey:@"baike"];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *dic in jsonArray) {
        ZJUWikiItem *item = [[ZJUWikiItem alloc] init];
        item.title = [dic valueForKey:@"title"];
        item.detail = [dic valueForKey:@"detail"];
        [resultArray addObject:item];
    }
    
    return [NSArray arrayWithArray:resultArray];
}
@end
