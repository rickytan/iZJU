//
//  ZJUOutsideRequest.m
//  iZJU
//
//  Created by ricky on 12-11-8.
//
//

#import "ZJUOutsideRequest.h"

@implementation ZJUOutsideListItem

@synthesize ID,title;
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID
                  forKey:@"id"];
    [aCoder encodeObject:self.title
                  forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.ID = [aDecoder decodeObjectForKey:@"id"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end

@implementation ZJUOutsideDetailItem

@synthesize title,details;
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.details
                  forKey:@"detail"];
    [aCoder encodeObject:self.title
                  forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.details = [aDecoder decodeObjectForKey:@"detail"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
@implementation ZJUOutsideRequest

- (NSURL*)url
{
    //#ifdef DEBUG
    //    return [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.json"]];
    //#else
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@",[self host],@"data",@"jiaoliu.php"]];
    //#endif
}

- (id)handler:(id)data
        error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    if (*outError)
        return nil;
    
    NSArray *jsonArray = (NSArray *)json;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *data in jsonArray) {
        ZJUOutsideListItem *item = [[ZJUOutsideListItem alloc] init];
        item.ID = [data objectForKey:@"id"];
        item.title = [data objectForKey:@"title"];
        
        [results addObject:item];
    }
    return [NSArray arrayWithArray:results];
}
@end

@implementation ZJUOutsideDetailRequest

- (NSURL*)url
{
    //#ifdef DEBUG
    //    return [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.json"]];
    //#else
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@?id=%@",[self host],@"data",@"jiaoliu.php",self.ID]];
    //#endif
}

- (id)handler:(id)data
        error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    if (*outError) {
        return nil;
    }
    
    ZJUOutsideDetailItem *item = [[ZJUOutsideDetailItem alloc] init];
    item.title = [json objectForKey:@"title"];
    item.details = [json objectForKey:@"detail"];
    return item;
}
@end
