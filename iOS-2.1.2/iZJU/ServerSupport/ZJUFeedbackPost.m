//
//  ZJUFeedbackPost.m
//  iZJU
//
//  Created by ricky on 12-11-10.
//
//

#import "ZJUFeedbackPost.h"

@implementation ZJUFeedbackPost
@synthesize email = _email, message = _message;

- (NSData*)getPostData
{
    NSString *dataString = [NSString stringWithFormat:@"suggest=%@&email=%@",_message,_email?_email:@""];
    return [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL*)url
{
    //#ifdef DEBUG
    //    return [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.json"]];
    //#else
    return [NSURL URLWithString:[NSString stringWithFormat:
                                 @"http://%@/%@/%@",[self host],@"data",@"suggest.php"]];
    //#endif
}

- (void)requestHook:(NSMutableURLRequest *)request
{
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self getPostData]];
}

- (id)handler:(id)data error:(NSError *__autoreleasing *)outError
{
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:outError];
    if (*outError)
        return nil;
    
    return json;
}
@end
